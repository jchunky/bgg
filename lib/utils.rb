module Utils
  extend self

  def read_html(url)
    strip_accents(read_html_raw(url))
  end

  def read_json(url)
    strip_accents(read_json_raw(url))
  end

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  def cache_object(id)
    file = filename(id, "yml")
    return yaml_read(file) if File.exist?(file)

    result = yield
    File.write(file, YAML.dump(result))
    result
  end

  def cache_text(id, extension:)
    file = filename(id, extension)
    return File.read(file) if File.exist?(file)

    result = yield
    File.write(file, result)
    result
  end

  private

  def read_html_raw(url)
    cache_text(url, extension: "html") { open(url) }
  end

  def read_json_raw(url)
    cache_text(url, extension: "json") do
      url = URI.parse(url)
      response = Net::HTTP.get_response(url)

      unless response.is_a?(Net::HTTPSuccess)
        raise "Failed to retrieve JSON data. HTTP Error: #{response.code}"
      end

      response.body
    end
  end

  def yaml_read(file)
    YAML.safe_load(File.read(file), aliases: true, permitted_classes: [Game, Symbol])
  end

  def open(url)
    Net::HTTP.get(URI.parse(url))
  end

  def filename(id, extension)
    ".data/#{id.gsub(/\W/, '-')}.#{extension}"
  end
end
