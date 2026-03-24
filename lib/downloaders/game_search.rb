# frozen_string_literal: true

module Downloaders
  class GameSearch < Struct.new(:listid, :prefix, :search_criteria)
    include Concerns::Paginator

    def games
      @games ||= fetch_all_ranked_games
        .uniq(&:key)
        .each.with_index(1) { |game, index| game.send(:"#{prefix}_rank=", index) }
        .select { |game| game.rank.positive? }
    end

    private

    def fetch_all_ranked_games
      (0..).each.with_object([]) do |_, result|
        @min_rank_filter = result.filter_map { |g| g.rank if g.rank.positive? }.max.to_i + 1 unless result.empty?
        band_games = content_for_pages
        result.concat(band_games)
        return result if band_games.none? { |g| g.rank.positive? }
      end
    end

    def search_completed?(games)
      if search_criteria.include?("sort=rank")
        games.none? { |g| g.rank.positive? }
      else
        games.none?
      end
    end

    def fetch_games_for_page(page)
      url = url_for_page(page)
      Utils::HttpFetcher.html(url, crawl_delay: 5) { parse_games_from_doc(it) }
    end

    def url_for_page(page)
      url = "https://boardgamegeek.com/search/boardgame/page/#{page}?advsearch=1&#{search_criteria}"
      url += "&range[rank][min]=#{@min_rank_filter}" if @min_rank_filter
      url
    end

    def parse_games_from_doc(doc)
      rows(doc).map { build_game(it) }
    rescue NoMethodError
      []
    end

    def rows(doc)
      doc
        .css(".collection_table")[0]
        .css("tr")
        .select { |row| row.css("td")[4] }
    end

    def build_game(row)
      c1, _, c3, _, c5, c6 = row.css("td")
      a1 = c1.css("a")[0]
      a3 = c3.css("a")[0]
      span3 = c3.css("span")[0]

      Models::Game.new(
        href: a3["href"],
        name: a3.content,
        rating: c5.content.to_f,
        rating_count: c6.content.to_i,
        year: (span3.content[1..-2].to_i rescue 0),
        rank: (a1["name"].to_i rescue 0),
      )
    end
  end
end
