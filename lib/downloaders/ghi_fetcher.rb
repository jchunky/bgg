module Downloaders
  GhiFetcher = Struct.new(:game) do
    def ghi
      @ghi ||= calculate_ghi
    end

    private

    def calculate_ghi
      n = 0
      page = 1
      loop do
        play_counts = fetch_page_data(page) { |doc| extract_play_counts(doc) }
        break if play_counts.empty?

        play_counts.each do |count|
          n += 1
          return n if count < n
        end

        page += 1
      end

      n
    end

    def fetch_page_data(page, &)
      url = url_for_page(page)
      Utils.fetch_html_data(url, &)
    end

    def url_for_page(page)
      "https://boardgamegeek.com/playstats/thing/#{game.key}/page/#{page}"
    end

    def extract_play_counts(doc)
      rows = doc.css(".forum_table td.lf a")
      rows.map(&:content).map(&:to_i)
    end
  end
end
