module Utils
  class HttpFetcher < Struct.new(:url, keyword_init: true)
    def self.html(url, &)
      new(url:).fetch_html(&)
    end

    def self.json(url, &)
      new(url:).fetch_json(&)
    end

    def fetch_html
      cached_content("html") { |content| yield Nokogiri::HTML(content) }
    end

    def fetch_json
      cached_content("json") { |content| yield JSON.parse(content) }
    end

    private

    def cached_content(extension, &)
      Utils::CachedFile.new(url:, extension:).read(&)
    end
  end
end
