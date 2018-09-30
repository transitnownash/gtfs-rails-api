class Shape < ApplicationRecord
  belongs_to :trip

  default_scope { order(shape_pt_sequence: :asc) }

  def self.hash_from_gtfs(row)
    record = {}
    record[:shape_gid] = row.id
    record[:shape_pt_lat] = row.pt_lat
    record[:shape_pt_lon] = row.pt_lon
    record[:shape_pt_sequence] = row.pt_sequence
    record[:shape_dist_traveled] = row.dist_traveled
    record
  end
end
