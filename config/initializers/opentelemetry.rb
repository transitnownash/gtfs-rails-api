# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::ActiveSupport'
  c.use 'OpenTelemetry::Instrumentation::Rack'
  c.use 'OpenTelemetry::Instrumentation::ActionPack'
  c.use 'OpenTelemetry::Instrumentation::ActiveJob'
  c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
  c.use 'OpenTelemetry::Instrumentation::ActionView'
  c.use 'OpenTelemetry::Instrumentation::ConcurrentRuby'
  c.use 'OpenTelemetry::Instrumentation::Mysql2'
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
  c.use 'OpenTelemetry::Instrumentation::Rails'
end
