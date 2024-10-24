module Downloaders
  class TopPlayed < Struct.new(:prefix, :listid, keyword_init: true)
    def games
      @games ||= (1..10)
                 .flat_map(&method(:fetch_games_for_page))
                 .compact
                 .uniq(&:key)
                 .sort_by(&:unique_users)
                 .reverse_each.with_index(1) { |game, index| game.send("#{prefix}_rank=", index) }
    end

    private

    def fetch_games_for_page(page)
      url = url_for_page(page)
      Utils.fetch_html_data(url, &method(:parse_games_from_doc))
    end

    def url_for_page(page)
      end_date = Date.yesterday
      start_date = end_date - 30.days

      "https://boardgamegeek.com/plays/bygame/subtype/boardgame/start/#{start_date}/end/#{end_date}/page/#{page}"
    end

    def parse_games_from_doc(doc)
      rows(doc).map(&method(:build_game))
    end

    def rows(doc)
      doc
        .css(".forum_table")[1]
        .css("tr")
        .select { |row| row.css("td")[0] }
    end

    def build_game(row)
      c1, _, c3 = row.css("td")
      a1 = c1.css("a")[0]
      a3 = c3.css("a")[0]

      Game.new(
        href: a1["href"],
        name: a1.content,
        unique_users: a3.content.to_i
      )
    end
  end
end
