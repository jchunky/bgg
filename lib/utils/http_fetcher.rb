module Utils
  class HttpFetcher < Struct.new(:url, keyword_init: true)
    def self.html(url, &block)
      new(url:).fetch_html(&block)
    end

    def self.json(url, &block)
      new(url:).fetch_json(&block)
    end

    def fetch_html
      cached_content("html") { |content| yield Nokogiri::HTML(content) }
    end

    def fetch_json
      cached_content("json") { |content| yield JSON.parse(content) }
    end

    private

    def cached_content(extension, &block)
      Utils::CachedFile.new(url:, extension:).read(&block)
    end
  end
end
