# frozen_string_literal: true

# Configured entirely through the standard OTEL_* environment variables
# (OTEL_SERVICE_NAME, OTEL_RESOURCE_ATTRIBUTES, etc.).
if ENV['OTEL_EXPORTER_OTLP_ENDPOINT'].present?
  require 'opentelemetry/sdk'
  require 'opentelemetry/exporter/otlp'
  require 'opentelemetry/instrumentation/mysql2'
  require 'opentelemetry/instrumentation/net/http'
  require 'opentelemetry/instrumentation/rails'

  OpenTelemetry::SDK.configure(&:use_all)
end
