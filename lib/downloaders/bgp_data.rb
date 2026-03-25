# frozen_string_literal: true

module Downloaders
  class BgpData
    BASE_URL = "https://www.boardgameprices.com"
    CRAWL_DELAY = 1
    EUR_TO_CAD = 1.58

    CANADIAN_STORES = {
      574 => "BoardGamesNMore",
      551 => "Cardboard Hero",
      275 => "Le Valet D'Coeur",
      519 => "Shadowborne Games",
    }.freeze

    def prefix = :bgp
    def listid = "bgp_data"

    def games
      @games ||= CANADIAN_STORES
        .flat_map { |id, store| fetch_store(id, store) }
        .group_by(&:key)
        .values
        .map { |dupes| combine(dupes) }
    end

    private

    def fetch_store(store_id, store_name)
      (1..).each.with_object([]) do |page, result|
        doc = fetch_page(store_id, page)
        games = parse_games(doc, store_name)
        result.concat(games)
        break result unless next_page?(doc)
      end
    end

    def fetch_page(store_id, page)
      url = "#{BASE_URL}/store/stuffers/#{store_id}?page=#{page}"
      Utils::HttpFetcher.html(url, crawl_delay: CRAWL_DELAY) { it }
    end

    def parse_games(doc, store_name)
      doc.css("div.searchinfocontainer").filter_map do |container|
        name = container.at_css("span.name")&.text&.strip
        price_text = container.at_css("span.price")&.text
        link = container.at_css("a")&.[]("href")
        next if name.blank? || price_text.nil?

        eur_price = price_text.delete("€").strip.tr(",", ".").to_f
        cad_price = (eur_price * EUR_TO_CAD).round
        product_url = link ? "#{BASE_URL}#{link}" : nil

        Models::Game.new(
          name:,
          bgp: true,
          bgp_price: cad_price,
          bgp_store_links: { store_name => product_url },
        )
      end
    end

    def combine(dupes)
      links = dupes.map(&:bgp_store_links).reduce(:merge)
      best_price = dupes.map(&:bgp_price).min

      Models::Game.new(
        name: dupes.first.name,
        bgp: true,
        bgp_price: best_price,
        bgp_store_links: links,
      )
    end

    def next_page?(doc)
      doc.text.include?("Next")
    end
  end
end
