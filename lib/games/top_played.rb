class TopPlayed
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
  end

  def months_data
    first = Date.parse('2005-01-01')
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def url_for_month_and_page(month, page)
    "https://boardgamegeek.com/plays/bygame/start/#{month.beginning_of_month}/end/#{month.end_of_month}/page/#{page}?sortby=distinctusers"
  end

  def games_for_doc(month, doc)
    doc.css('.forum_table')[1].css('tr')[1..-2].map do |row|
      link, _, plays = row.css('td')
      anchor = link.css('a')
      href = anchor[0]['href']
      name = anchor[0].content
      key = Utils.generate_key(name)
      play_count = plays.css('a')[0].content.to_i

      next if play_count < 1

      game = OpenStruct.new(href: href, name: name, key: key, players: {})
      game.players[month.to_s] = play_count
      game
    end.compact
  rescue
    []
  end
end
