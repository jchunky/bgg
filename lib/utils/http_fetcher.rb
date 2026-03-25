# frozen_string_literal: true

module Utils
  class HttpFetcher < Data.define(:url, :crawl_delay)
    def self.html(url, crawl_delay:, &) = new(url:, crawl_delay:).fetch_html(&)
    def self.json(url, crawl_delay:, &) = new(url:, crawl_delay:).fetch_json(&)
    def self.xml(url, crawl_delay:, &) = new(url:, crawl_delay:).fetch_xml(&)

    def fetch_html = cached_content("html") { |content| yield Nokogiri::HTML(content) }
    def fetch_json = cached_content("json") { |content| yield JSON.parse(content) }
    def fetch_xml = cached_content("xml") { |content| yield Nokogiri::XML(content) }

    private

    def cached_content(extension, &)
      Utils::CachedFile.new(url:, extension:, crawl_delay:).read(&)
    end
  end
end
