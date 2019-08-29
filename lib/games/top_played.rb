class TopPlayed
  NUMBER_OF_MONTHS = 12

  def games
    months_data.product((1..10).to_a)
      .lazy
      .map { |month, page| [month, url_for_month_and_page(month, page)] }
      .map { |month, url| [month, Utils.read_url(url)] }
      .map { |month, file| [month, Nokogiri::HTML(file)] }
      .flat_map { |month, doc| games_for_doc(month, doc) }
      .force
      .each_with_object({}) do |game, memo|
        memo[game.name] ||= game
        memo[game.name].players = game.players.merge(memo[game.name].players)
      end
      .values
      .tap { |games| add_player_count(games) }
  end

  def months_data
    first = Date.parse('2005-01-01')
    last = last_month
    (first..last)
      .select { |d| d.day == 1 }
      .last(NUMBER_OF_MONTHS)
  end

  def url_for_month_and_page(month, page)
    "https://boardgamegeek.com/plays/bygame/start/#{month.beginning_of_month}/end/#{month.end_of_month}/page/#{page}?sortby=distinctusers"
  end

  def games_for_doc(month, doc)
    doc.css('.forum_table')[1].css('tr')[1..-1].map do |row|
      link, _, plays = row.css('td')
      anchor = link.css('a')
      href = anchor[0]['href']
      name = anchor[0].content
      play_count = plays.css('a')[0].content.to_i

      next if play_count < 1

      game = OpenStruct.new(href: href, name: name, players: {})
      game.players[month.to_s] = play_count
      game
    end.compact
  rescue
    []
  end

  def add_player_count(games)
    games.each do |game|
      game.player_count = game.players.to_h[last_month.to_s].to_i
    end
  end

  def last_month
    @last_month ||= (Date.today - 1.month).beginning_of_month
  end
end
