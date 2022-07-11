class Shape < ApplicationRecord
  has_many :trips

  def as_json(_options = {})
    super(
      only: [:id, :shape_gid],
      methods: ['points']
    )
  end

  def points
    JSON.parse(shape_points)
  end

  def self.hash_from_gtfs(row)
    record = {}
    record[:shape_gid] = row[:shape_gid]
    record[:shape_points] = row[:shape_points].to_json
    record
  end
end
