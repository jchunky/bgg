module Utils
  extend self

  def read_url(url)
    strip_accents(read_url_raw(url))
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

  def cache_text(id)
    file = filename(id, "html")
    return File.read(file) if File.exist?(file)

    result = yield
    File.write(file, result)
    result
  end

  private

  def read_url_raw(url)
    cache_text(url) { open(url) }
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
