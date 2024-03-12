module Downloaders
  class ReplaysFetcher < Struct.new(:href, keyword_init: true)
    def replays
      @replays ||= begin
        doc = fetch_page_data(tenth_percentile_page)
        rows = doc.css(".forum_table td.lf a")
        if rows.count.zero?
          0
        else
          index = (page_count % 10) / 10.0 * rows.count
          rows[index].content.to_i
        end
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

    def page_count
      @page_count ||= begin
        doc = fetch_page_data(1)
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

    def fetch_page_data(page)
      url = url_for_page(page)
      Utils.fetch_html_data(url)
    end

    def url_for_page(page)
      "https://boardgamegeek.com/playstats/thing/#{objectid}/page/#{page}"
    end

    def objectid
      href.scan(/\b\d+\b/).first.to_i
    end
  end
end
