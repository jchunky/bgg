class Utils
  def self.fetch_html_data(url)
    file = CachedFile.new(url: url, extension: "html")
    Nokogiri::HTML(file.read)
  end

  def self.fetch_json_data(url)
    file = CachedFile.new(url: url, extension: "json")
    JSON.parse(file.read)
  end
end
