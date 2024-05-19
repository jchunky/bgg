module Downloaders
  class CategoryGames < Struct.new(:listid, :prefix, :items_per_page, :object_type, keyword_init: true)
    def games
      content_for_pages(&method(:games_for_page))
        .uniq(&:key)
        .select { |g| g.rank.between?(1, 5000) }
    end

    private

    def content_for_pages(&block)
      (1..).each.with_object([]) do |page, result|
        games = block.call(page)
        result.concat(games)
        return result if games.none? { |g| g.rank.between?(1, 5000) }
      end
    end

    def games_for_page(page)
      Array(listid).flat_map do |listid|
        url = url_for_page(page, listid)
        doc = Utils.fetch_json_data(url)
        games_for_doc(doc, page)
      end
    end

    def url_for_page(page, listid)
      <<~URL.remove(/\s/)
        https://api.geekdo.com/api/geekitem/linkeditems
          ?linkdata_index=boardgame
          &objectid=#{listid}
          &objecttype=#{object_type}
          &showcount=#{items_per_page}
          &sort=rank
          &pageid=#{page}
      URL
    end

    def games_for_doc(doc, page)
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
