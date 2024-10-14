require "open-uri"

class CachedFile < Struct.new(:url, :extension, keyword_init: true)
  BGG_CRAWL_DELAY = 2
  CACHE_EXPIRY = 24.hours

  def read
    return File.read(file) if File.exist?(file) && (Time.now - File.mtime(file)) < CACHE_EXPIRY

    sleep BGG_CRAWL_DELAY
    print "."
    result = URI.open(url).read
    File.write(file, result)
    result
  rescue StandardError => e
    puts "[ERROR] Failed to process URL: #{url}"
    puts "[DETAILS] Exception: #{e.message}"
    puts "File: #{file}"
    exit
  end

  private

  def file
    @file ||= ".data/#{url.gsub(/\W/, '-')}.#{extension}"
  end
end
