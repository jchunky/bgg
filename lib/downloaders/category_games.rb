module Downloaders
  class CategoryGames < Struct.new(:listid, :prefix, :page_count, :object_type, keyword_init: true)
    ITEMS_PER_PAGE = 50

    def games
      (1..page_count)
        .flat_map(&method(:games_for_page))
        .compact
        .uniq(&:key)
    end

    private

    def games_for_page(page)
      url = url_for_page(page)
      doc = Utils.fetch_json_data(url)
      games_for_doc(doc, page)
    end

    def url_for_page(page)
      "https://api.geekdo.com/api/geekitem/linkeditems?linkdata_index=boardgame&objectid=#{listid}&objecttype=#{object_type}&showcount=#{ITEMS_PER_PAGE}&sort=rank&pageid=#{page}"
    end

    def games_for_doc(doc, page)
      doc["items"].map.with_index do |game, i|
        Game.new(
          href: game["href"],
          name: game["name"],
          rank: game["rank"].to_i,
          rating: game["average"].to_f,
          rating_count: game["usersrated"].to_i,
          weight: game["avgweight"].to_f,
          year: game["yearpublished"].to_i,
          "#{prefix}_rank": ((page - 1) * ITEMS_PER_PAGE) + i + 1
        )
      end
    end
  end
end
