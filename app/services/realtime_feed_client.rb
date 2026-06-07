# frozen_string_literal: true

require 'net/http'
require 'uri'

class RealtimeFeedClient
  FETCH_TIMEOUT = 5
  Error = Class.new(StandardError)

  def fetch(url)
    raise Error, 'Missing realtime feed URL' if url.blank?

    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port,
                    open_timeout: FETCH_TIMEOUT,
                    read_timeout: FETCH_TIMEOUT,
                    use_ssl: uri.scheme == 'https') do |http|
      response = http.get(uri.request_uri)
      raise Error, "Realtime feed returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end
  rescue URI::InvalidURIError, Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
         Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    Rails.logger.error("Realtime feed fetch failed for #{url}: #{e.class}: #{e.message}")
    raise Error, 'Failed to fetch realtime feed'
  end
end
