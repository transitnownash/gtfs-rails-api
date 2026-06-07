# frozen_string_literal: true

require 'test_helper'
require 'rake'

class ImportTaskTest < ActiveSupport::TestCase
  Rails.application.load_tasks unless Rake::Task.task_defined?('import:verify')

  setup do
    @task = Rake::Task['import:verify']
    @original_gtfs_url = ENV['GTFS_URL']
    @task.reenable
  end

  teardown do
    ENV['GTFS_URL'] = @original_gtfs_url
    @task.reenable
  end

  test 'verify exits with a clear error when GTFS_URL is missing' do
    ENV.delete('GTFS_URL')

    stdout, = capture_io do
      error = assert_raises(SystemExit) { @task.invoke }
      assert_equal 1, error.status
    end

    assert_includes stdout, '[ERROR] GTFS_URL is not configured.'
  end
end
