# frozen_string_literal: true

##
# Shape Model
class Shape < ApplicationRecord
  has_many :trips, dependent: :destroy

  def as_json(_options = {})
    super(
      only: %i[id shape_gid],
      methods: ['points']
    )
  end

  # Preloaded trips share Shape instances, so parse once per shape, not per trip.
  def points
    @points ||= JSON.parse(shape_points)
  end

  def self.hash_from_gtfs(row)
    record = {}
    record[:shape_gid] = row[:shape_gid]
    record[:shape_points] = row[:shape_points].to_json
    record
  end
end
