module Downloaders
  class TopPlayed < Struct.new(:prefix, :listid, keyword_init: true)
    def games
      (1..10)
        .flat_map(&method(:games_for_page))
        .compact
        .uniq(&:key)
    end

    private

    def games_for_page(page)
      url = url_for_page(page)
      doc = Utils.fetch_html_data(url)
      games_for_doc(doc, page)
    end

    def url_for_page(page)
      end_date = Date.yesterday
      start_date = end_date - 30.days

      "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{start_date}/end/#{end_date}/page/#{page}"
    end

    def games_for_doc(doc, page)
      doc.css(".forum_table")[1].css("tr")
        .select { |row| row.css("td")[0] }
        .map(&method(:game_for_row))
        .sort_by(&:unique_users)
        .reverse
        .each.with_index do |game, i|
          game.play_rank = ((page - 1) * 100) + i + 1
        end
    rescue StandardError
      []
    end

    def game_for_row(row)
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
