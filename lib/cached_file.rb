require "open-uri"

class CachedFile < Struct.new(:url, :extension, keyword_init: true)
  BGG_CRAWL_DELAY = 2
  CACHE_EXPIRY = 24.hours

  def read
    File.write(file, fetch_from_url) if cache_expired?
    File.read(file)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def fetch_from_url
    sleep BGG_CRAWL_DELAY
    print "."
    URI.open(url).read
  end

  def cache_expired?
    !File.exist?(file) || File.mtime(file) < (Time.now - CACHE_EXPIRY)
  end

  def file
    @file ||= ".data/#{sanitized_filename}.#{extension}"
  end

  def sanitized_filename
    url.gsub(/\W/, "-")
  end

  def handle_error(e)
    puts "[ERROR] Failed to process URL: #{url}"
    puts "[DETAILS] Exception: #{e.message}"
    puts "File: #{file}"
    exit
  end
end
