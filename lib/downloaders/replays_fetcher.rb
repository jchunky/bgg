module Downloaders
  ReplaysFetcher = Struct.new(:game) do
    def replays
      @replays ||= fetch_page_data(tenth_percentile_page) do |doc|
        rows = doc.css(".forum_table td.lf a")
        rows.any? ? rows[row_index(rows)].content.to_i : 0
      end
    end

    private

    def tenth_percentile_page
      if page_count >= 10 && page_count % 10 == 0
        (page_count / 10) + 1
      else
        (page_count / 10.0).ceil
      end
    end

    def row_index(rows)
      (page_count % 10) / 10.0 * rows.count
    end

    def page_count
      @page_count ||= fetch_page_data(1) do |doc|
        last_page_anchor = doc.css('#maincontent p a[title="last page"]')
        pagination_anchors = doc.css("#maincontent p a")
        if last_page_anchor.count >= 1
          last_page_anchor.first.content.scan(/\d+/).first.to_i
        elsif pagination_anchors.count >= 2
          pagination_anchors[-2].content.to_i
        else
          1
        end
      end
    end

    def fetch_page_data(page, &block)
      url = url_for_page(page)
      Utils.fetch_html_data(url, &block)
    end

    def url_for_page(page)
      "https://boardgamegeek.com/playstats/thing/#{game.key}/page/#{page}"
    end
  end
end
