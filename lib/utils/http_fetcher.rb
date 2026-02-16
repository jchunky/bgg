module Utils
  HttpFetcher = Data.define(:url) do
    def self.html(url, &) = new(url:).fetch_html(&)
    def self.json(url, &) = new(url:).fetch_json(&)

    def fetch_html = cached_content("html") { |content| yield Nokogiri::HTML(content) }
    def fetch_json = cached_content("json") { |content| yield JSON.parse(content) }

    private

    def cached_content(extension, &) = Utils::CachedFile.new(url:, extension:).read(&)
  end
end
