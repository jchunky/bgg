require "open-uri"

module Utils
  extend self

  def fetch_json_data(url)
    file = Utils.read_file(url, extension: "json")
    JSON.parse(file)
  end

  def fetch_html_data(url)
    file = Utils.read_file(url, extension: "html")
    Nokogiri::HTML(file)
  end

  def read_file(url, extension:)
    cache_text(url, extension:) do
      file_contents = URI.open(url).read
      strip_accents(file_contents)
    end
  end

  private

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  def cache_text(id, extension:)
    file = filename(id, extension)
    return File.read(file) if File.exist?(file)

    result = yield
    File.write(file, result)
    result
  end

  def filename(id, extension)
    ".data/#{id.gsub(/\W/, '-')}.#{extension}"
  end
end
