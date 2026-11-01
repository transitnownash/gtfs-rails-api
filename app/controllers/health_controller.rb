# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :set_expires_in

  def show
    expires_now

    services = [
      database_service_status,
      realtime_alerts_service_status,
      static_schedule_data_service_status
    ]

    status = services.all? { |service| service[:status] == 'ok' } ? 'ok' : 'failing'
    render json: { status: status, services: services }, status: status == 'ok' ? :ok : :service_unavailable
  end

  private

  def database_service_status
    ApplicationRecord.connection.select_value('SELECT 1')
    healthy_service_status('database')
  rescue StandardError => e
    failing_service_status('database', e)
  end

  def realtime_alerts_service_status
    RealtimeFeeds.entities(:alerts)
    healthy_service_status('realtime_alerts')
  rescue StandardError => e
    failing_service_status('realtime_alerts', e)
  end

  def static_schedule_data_service_status
    raise StandardError, 'No agency records found' unless Agency.exists?

    healthy_service_status('static_schedule_data')
  rescue StandardError => e
    failing_service_status('static_schedule_data', e)
  end

  def healthy_service_status(name)
    { name: name, status: 'ok' }
  end

  def failing_service_status(name, error)
    Rails.logger.error("Healthcheck #{name} failed: #{error.class}: #{error.message}")
    { name: name, status: 'failing', error: error.message }
  end
end
