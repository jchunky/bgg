require "open-uri"

module Utils
  extend self

  BGG_CRAWL_DELAY = 2

  def fetch_html_data(url)
    file = read_cached_file(url, extension: "html")
    Nokogiri::HTML(file)
  rescue => ex
    log_error(ex, url, "html")
    exit
  end

  def fetch_json_data(url)
    file = read_cached_file(url, extension: "json")
    JSON.parse(file)
  rescue => ex
    log_error(ex, url, "json")
    exit
  end

  def read_cached_file(url, extension:)
    cache_file(url, extension: extension) do
      delayed_fetch(url)
    end
  end

  private

  def delayed_fetch(url)
    sleep BGG_CRAWL_DELAY
    print "."
    content = URI.open(url).read
    strip_accents(content)
  end

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  def cache_file(id, extension:)
    file = cache_filename(id, extension)
    return File.read(file) if File.exist?(file)

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
