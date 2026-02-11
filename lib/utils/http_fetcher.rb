module Utils
  class HttpFetcher
    def self.fetch_html_data(url)
      Utils::CachedFile.new(url:, extension: "html").read do |content|
        yield Nokogiri::HTML(content)
      end
    end

    def self.fetch_json_data(url)
      Utils::CachedFile.new(url:, extension: "json").read do |content|
        yield JSON.parse(content)
      end
    end
  end
end
