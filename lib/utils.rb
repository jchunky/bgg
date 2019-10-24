class Utils
  def self.generate_key(name)
    name
      .downcase
      .gsub("-", " ")
      .gsub(" and ", " & ")
      .gsub(/\bthe /, "")
      .gsub(/[^\w ]/, "")
      .gsub("(blackbox) - ", "")
      .gsub("(blackbox) ", "")
      .gsub("blackbox - ", "")
      .squish
  end

  def self.read_url(url)
    strip_accents(read_url_raw(url))
  end

  def self.strip_accents(string)
    ActiveSupport::Inflector.transliterate(string).to_s
  end

  private

  def self.read_url_raw(url)
    cache(url) { open(url) }
  end

  def self.cache(url)
    file = "tmp/" + url.gsub(/[:\/]/, '_') + ".html"
    File.write(file, yield) unless File.exist?(file)
    File.read(file)
  end

  def self.open(url)
    Net::HTTP.get(URI.parse(url))
  end
end