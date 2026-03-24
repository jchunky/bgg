# frozen_string_literal: true

require "open-uri"

module Utils
  class CachedFile < Data.define(:url, :extension, :crawl_delay)
    CACHE_EXPIRY = 1.year
    DEFAULT_CRAWL_DELAY = 5

    def initialize(url:, extension:, crawl_delay: DEFAULT_CRAWL_DELAY)
      super(url:, extension:, crawl_delay:)
    end

    def read
      content = cache_expired? ? fetch_from_url : File.read(file)
      result = yield(content)
      File.write(file, content) if cache_expired?
      result
    rescue StandardError => e
      handle_error(e)
    end

    private

    def fetch_from_url
      sleep crawl_delay
      print "."
      URI.parse(url).open.read
    end

    def cache_expired?
      !File.exist?(file) || File.mtime(file) < (Time.now - CACHE_EXPIRY)
    end

    def file = ".data/#{sanitized_filename}.#{extension}"

    def sanitized_filename = url.gsub(/\W/, "-")

    def handle_error(error)
      puts <<~ERROR
        [ERROR] <#{error.class}>: #{error.message[0, 150]}
        URL: #{url}
        File: #{file}
        Stacktrace: #{error.backtrace.first(10).join("\n")}
      ERROR
      exit(-1)
    end
  end
end
