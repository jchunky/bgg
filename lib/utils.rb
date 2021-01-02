class Utils
  def self.read_url(url)
    strip_accents(read_url_raw(url))
  end

  def self.strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  private

  def self.read_url_raw(url)
    cache(url) { open(url) }
  end

  def self.cache(url)
    file = ".data/#{url.gsub(%r{[:/]}, '_')}.html"
    File.write(file, yield) unless File.exist?(file)
    File.read(file)
  end

  def self.open(url)
    Net::HTTP.get(URI.parse(url))
  end
end
