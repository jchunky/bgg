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
      doc = fetch_page_data(page)
      games_for_doc(doc, page)
    end

    def fetch_page_data(page)
      url = url_for_page(page)
      file = Utils.read_file(url, extension: "json")
      JSON.parse(file)
    end

    def url_for_page(page)
      "https://api.geekdo.com/api/geekitem/linkeditems?linkdata_index=boardgame&objectid=#{listid}&objecttype=#{object_type}&showcount=#{ITEMS_PER_PAGE}&sort=rank&pageid=#{page}"
    end

    def games_for_doc(doc, page)
      doc["items"].map.with_index do |item, i|
        Game.new(
          href: item["href"],
          key: item["href"],
          name: item["name"],
          rank: item["rank"].to_i,
          rating: item["average"].to_f,
          rating_count: item["usersrated"].to_i,
          weight: item["avgweight"].to_f,
          year: item["yearpublished"].to_i,
          "#{prefix}_rank": ((page - 1) * ITEMS_PER_PAGE) + i + 1
        )
      end
    end
  end
end
