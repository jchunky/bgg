# frozen_string_literal: true

require "open-uri"

module Utils
  class CachedFile < Data.define(:url, :extension, :crawl_delay)
    def read
      content = cache_miss? ? fetch_from_url : File.read(file)
      result = yield(content)
      File.write(file, content) if cache_miss?
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

    def cache_miss?
      !File.exist?(file)
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
