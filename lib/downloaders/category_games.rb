module Downloaders
  class CategoryGames < Struct.new(:listid, :prefix, :items_per_page, :object_type)
    include Paginator

    def games
      @games ||= content_for_pages
        .uniq(&:key)
        .select { |game| game.rank.positive? }
    end

    private

    def search_completed?(games)
      games.none? { |g| g.rank.positive? }
    end

    def fetch_games_for_page(page)
      Array(listid).flat_map do |listid|
        url = url_for_page(page, listid)
        Utils::HttpFetcher.fetch_json_data(url) { parse_games_for_doc(_1) }
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
      rows(doc).map { build_game(_1) }
    end

    def rows(doc)
      doc["items"]
    end

    def build_game(row)
      Models::Game.new(
        href: row.dig("href"),
        name: row.dig("name"),
        rank: row.dig("rank").to_i,
        rating: row.dig("average").to_f,
        rating_count: row.dig("usersrated").to_i,
        weight: row.dig("avgweight").to_f,
        year: row.dig("yearpublished").to_i,
        "#{prefix}_rank": row.dig("rank").to_i
      )
    end
  end
end
