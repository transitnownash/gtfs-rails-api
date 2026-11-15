# frozen_string_literal: true

# Blue-green GTFS import: load the feed into *_staging tables, validate, then
# swap them in with one atomic RENAME TABLE. The prior data is kept as *_old.
module GtfsImport
  class ValidationError < StandardError; end

  MODELS = [
    Agency, Calendar, CalendarDate, FareAttribute, FareRule, FeedInfo, Frequency,
    Route, Shape, Stop, StopTime, Transfer, Trip
  ].freeze
  REQUIRED = [Agency, Stop, Route, Trip, StopTime].freeze
  SHRINK_GUARDED = [Trip, StopTime].freeze
  MIN_RATIO = 0.5

  module_function

  # insert_all requires identical keys on every row; hash_from_gtfs omits
  # unresolved foreign keys, so fill gaps with the column default.
  def bulk_load(model, rows, batch_size: 500, upsert: true)
    rows.each_slice(batch_size) do |batch|
      keys = batch.flat_map(&:keys).uniq
      batch = batch.map { |row| keys.index_with { |k| row.fetch(k) { model.column_defaults[k.to_s] } } }
      upsert ? model.upsert_all(batch) : model.insert_all(batch) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def missing_tables
    missing = REQUIRED.reject(&:exists?).map(&:table_name)
    missing << "#{Calendar.table_name}/#{CalendarDate.table_name}" unless Calendar.exists? || CalendarDate.exists?
    missing
  end

  def live_tables
    MODELS.map { |model| model.table_name.delete_suffix('_staging') }
  end

  def prepare_staging!
    drop_tables!('_staging', '_old')
    live_tables.each do |t|
      connection.execute("CREATE TABLE #{q("#{t}_staging")} LIKE #{q(t)}")
    end
  end

  def drop_tables!(*suffixes)
    names = live_tables.product(suffixes).map { |t, s| q("#{t}#{s}") }
    connection.execute("DROP TABLE IF EXISTS #{names.join(', ')}")
  end

  def with_staging
    originals = MODELS.index_with(&:table_name)
    MODELS.each { |model| model.table_name = "#{originals[model]}_staging" }
    yield
  ensure
    originals&.each { |model, name| model.table_name = name }
  end

  def validate_staging!(force: false)
    missing = missing_tables
    raise ValidationError, "No records found in: #{missing.join(', ')}" if missing.any?
    return if force

    SHRINK_GUARDED.each do |model|
      live = connection.select_value("SELECT COUNT(*) FROM #{q(model.table_name.delete_suffix('_staging'))}").to_i
      staged = model.count
      next if live.zero? || staged >= live * MIN_RATIO

      raise ValidationError,
            "#{model.table_name} has #{staged} rows vs #{live} live (< #{(MIN_RATIO * 100).to_i}%); " \
            'rerun with FORCE=1 if the feed really shrank'
    end
  end

  def swap!
    rename!(live_tables.flat_map { |t| [[t, "#{t}_old"], ["#{t}_staging", t]] })
  end

  def rollback!
    missing = live_tables.reject { |t| connection.table_exists?("#{t}_old") }
    raise ValidationError, "No previous import to roll back to (missing: #{missing.join(', ')})" if missing.any?

    rename!(live_tables.flat_map { |t| [[t, "#{t}_staging"], ["#{t}_old", t]] })
  end

  def rename!(pairs)
    connection.execute("RENAME TABLE #{pairs.map { |from, to| "#{q(from)} TO #{q(to)}" }.join(', ')}")
  end

  def connection
    ApplicationRecord.connection
  end

  def q(name)
    connection.quote_table_name(name)
  end
end
