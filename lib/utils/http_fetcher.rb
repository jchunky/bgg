# frozen_string_literal: true

module Utils
  class HttpFetcher < Data.define(:url, :crawl_delay)
    def self.html(url, crawl_delay: nil, &) = new(url:, crawl_delay:).fetch_html(&)
    def self.json(url, crawl_delay: nil, &) = new(url:, crawl_delay:).fetch_json(&)

    def fetch_html = cached_content("html") { |content| yield Nokogiri::HTML(content) }
    def fetch_json = cached_content("json") { |content| yield JSON.parse(content) }

    private

    def cached_content(extension, &)
      options = { url:, extension: }
      options[:crawl_delay] = crawl_delay if crawl_delay
      Utils::CachedFile.new(**options).read(&)
    end
  end
end
