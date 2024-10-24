module Downloaders
  class CategoryGames < Struct.new(:listid, :prefix, :items_per_page, :object_type, keyword_init: true)
    def games
      @games ||= content_for_pages
                 .uniq(&:key)
                 .select { |game| game.rank.between?(1, 5000) }
    end

    private

    def content_for_pages
      (1..).each.with_object([]) do |page, result|
        games = fetch_games_for_page(page)
        result.concat(games)
        return result if search_completed?(games)
      end
    end

    def search_completed?(games)
      games.none? { |g| g.rank.between?(1, 5000) }
    end

    def fetch_games_for_page(page)
      Array(listid).flat_map do |listid|
        url = url_for_page(page, listid)
        Utils.fetch_json_data(url, &method(:parse_games_for_doc))
      end
    end

    def url_for_page(page, listid)
      base_url = "https://api.geekdo.com/api/geekitem/linkeditems"
      query_params = {
        linkdata_index: "boardgame",
        objectid: listid,
        objecttype: object_type,
        showcount: items_per_page,
        sort: "rank",
        pageid: page,
      }
      "#{base_url}?#{URI.encode_www_form(query_params)}"
    end

    def parse_games_for_doc(doc)
      rows(doc).map(&method(:build_game))
    end

    def rows(doc)
      doc["items"]
    end

    def build_game(row)
      Game.new(
        href: row["href"],
        name: row["name"],
        rank: row["rank"].to_i,
        rating: row["average"].to_f,
        rating_count: row["usersrated"].to_i,
        weight: row["avgweight"].to_f,
        year: row["yearpublished"].to_i,
        "#{prefix}_rank": row["rank"].to_i
      )
    end
  end
end
