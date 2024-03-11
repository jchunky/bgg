require "open-uri"

module Utils
  extend self

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
