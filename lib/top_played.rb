class TopPlayed
  def self.months_data
    first = (Date.today - (Bgg::NUMBER_OF_MONTHS - 1).months).beginning_of_month
    last = last_month
    (first..last).select { |d| d.day == 1 }
  end

  def self.last_month
    Date.today.beginning_of_month
  end

  def games
    self.class.months_data.product((1..10).to_a)
      .lazy
      .map { |month, page| [month, page, url_for_year_and_page(month, page)] }
      .map { |month, page, url| [month, page, Utils.read_url(url)] }
      .map { |month, page, file| [month, page, Nokogiri::HTML(file)] }
      .flat_map { |month, page, doc| games_for_doc(month, page, doc) }
      .force
      .each_with_object({}) do |game, memo|
        memo[game.key] ||= game
        memo[game.key] = game.merge(memo[game.key])
      end
      .values
  end

  def url_for_year_and_page(year, page)
    start_date = year.beginning_of_month
    end_date = year.end_of_month

    "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{start_date}/end/#{end_date}/page/#{page}?sortby=distinctusers&subtype=All"
  end

  def games_for_doc(month, page, doc)
    doc.css(".forum_table")[1].css("tr").drop(1).map.with_index do |row, i|
      link, _, plays = row.css("td")
      anchor = link.css("a")
      name = Utils.strip_accents(anchor[0].content)
      play_count = plays.css("a")[0].content.to_i
      play_rank = (page - 1) * 100 + i + 1

      game = Game.new(
        href: href = anchor[0]["href"],
        name: name,
        key: href
      )
      game = game.add_player_count(month, play_count, play_rank)
      game
    end
  rescue StandardError
    []
  end
end
