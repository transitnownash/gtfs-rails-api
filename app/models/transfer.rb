# frozen_string_literal: true

class Transfer < ApplicationRecord
  has_one :from_stop, class_name: 'Stop'
  has_one :to_stop, class_name: 'Stop'

  def self.hash_from_gtfs(row)
    from_stop = Stop.find_by_stop_gid(row.from_stop_id)
    to_stop = Stop.find_by_stop_gid(row.to_stop_id)

    record = {}
    record[:from_stop_gid] = row.from_stop_id
    record[:from_stop_id] = from_stop.id unless from_stop.nil?
    record[:to_stop_gid] = row.to_stop_id
    record[:to_stop_id] = to_stop.id unless to_stop.nil?
    record[:transfer_type] = row.type || ''
    record[:min_transfer_time] = row.min_transfer_time
    record
  end
end
