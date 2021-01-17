module Utils
  extend self

  def read_url(url)
    strip_accents(read_url_raw(url))
  end

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  def cache_yaml(id)
    filename = filename(id, "yml")
    store = YAML::Store.new(filename)
    store.transaction do
      return store[id] if store[id]

      store[id] = yield
    end
  end

  private

  def read_url_raw(url)
    cache(url) { open(url) }
  end

  def cache(id)
    file = filename(id, "html")
    File.write(file, yield) unless File.exist?(file)
    File.read(file)
  end

  def open(url)
    Net::HTTP.get(URI.parse(url))
  end

  def filename(id, extension)
    ".data/#{id.gsub(/\W/, '-')}.#{extension}"
  end
end
