class FeedInfo < ApplicationRecord
  def self.hashFromGtfs(row)
    record = {}
    record[:feed_publisher_name] = row.publisher_name
    record[:feed_publisher_url] = row.publisher_url
    record[:feed_lang] = row.lang
    record[:feed_start_date] = row.start_date
    record[:feed_end_date] = row.end_date
    record[:feed_version] = row.version
    record
  end
end
