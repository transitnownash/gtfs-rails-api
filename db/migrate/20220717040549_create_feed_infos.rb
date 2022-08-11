# frozen_string_literal: true

##
# Create Feed Infos
class CreateFeedInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :feed_infos do |t|
      t.string 'feed_publisher_name', null: false
      t.string 'feed_publisher_url', null: false
      t.string 'feed_lang', null: false
      t.date 'feed_start_date'
      t.date 'feed_end_date'
      t.string 'feed_version'
      t.timestamps
    end
  end
end
