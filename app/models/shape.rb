class Shape < ApplicationRecord
  belongs_to :trip

  def self.hash_from_gtfs(row)
    record = {}
    record[:shape_gid] = row[:shape_gid]
    record[:shape_points] = row[:shape_points].to_json
    record
  end
end
