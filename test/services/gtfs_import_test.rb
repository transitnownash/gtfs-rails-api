# frozen_string_literal: true

require 'test_helper'

class GtfsImportTest < ActiveSupport::TestCase
  test 'with_staging points models at staging tables and restores them when the block raises' do
    assert_raises(RuntimeError) do
      GtfsImport.with_staging do
        assert_equal 'stop_times_staging', StopTime.table_name
        raise 'boom'
      end
    end

    assert_equal GtfsImport::MODELS.map { |m| m.name.underscore.pluralize }, GtfsImport::MODELS.map(&:table_name)
  end

  test 'missing_tables lists empty required tables' do
    assert_empty GtfsImport.missing_tables

    StopTime.delete_all
    CalendarDate.delete_all
    Calendar.delete_all

    assert_equal %w[stop_times calendars/calendar_dates], GtfsImport.missing_tables
  end
end
