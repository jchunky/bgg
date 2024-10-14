require "open-uri"

module Utils
  extend self

  BGG_CRAWL_DELAY = 2
  CACHE_EXPIRY = 24.hours

  def fetch_html_data(url)
    file = read_cached_file(url, extension: "html")
    Nokogiri::HTML(file)
  rescue StandardError => e
    log_error(e, url, "html")
    exit
  end

  def fetch_json_data(url)
    file = read_cached_file(url, extension: "json")
    JSON.parse(file)
  rescue StandardError => e
    log_error(e, url, "json")
    exit
  end

  private

  def read_cached_file(url, extension:)
    cache_file(url, extension: extension) do
      delayed_fetch(url)
    end
  end

  def delayed_fetch(url)
    sleep BGG_CRAWL_DELAY
    print "."
    URI.open(url).read
  end

  def cache_file(id, extension:)
    file = cache_filename(id, extension)
    return File.read(file) if File.exist?(file) && (Time.now - File.mtime(file)) < CACHE_EXPIRY

    result = yield
    File.write(file, result)
    result
  end

  def cache_filename(id, extension)
    ".data/#{id.gsub(/\W/, '-')}.#{extension}"
  end

  def log_error(ex, url, extension)
    puts "[ERROR] Failed to process URL: #{url}"
    puts "[DETAILS] Exception: #{ex.message}"
    puts "File: #{cache_filename(url, extension)}"
  end
end
