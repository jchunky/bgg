module Downloaders
  class CategoryGames < Struct.new(:listid, :prefix, :object_type, keyword_init: true)
    ITEMS_PER_PAGE = 50

    def games
      content_for_pages(&method(:games_for_page))
        .uniq(&:key)
        .reject { |g| g.rank.zero? }
    end

    private

    def content_for_pages(&block)
      (1..).each.with_object([]) do |page, result|
        games = block.call(page)
        return result if games.none? { |g| g.rank.positive? }
        result.concat(games)
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
          &showcount=#{ITEMS_PER_PAGE}
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
