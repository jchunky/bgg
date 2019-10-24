class TopPlayed
  def games
    (1..10)
      .lazy
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map(&method(:games_for_doc))
      .uniq { |game| game[:name] }
      .force
  end

  def url_for_page(page)
    "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{last_month.beginning_of_month}/end/#{last_month.end_of_month}/page/#{page}?sortby=distinctusers"
  end

  def games_for_doc(doc)
    doc.css('.forum_table')[1].css('tr')[1..-1].map do |row|
      link, _, plays = row.css('td')
      anchor = link.css('a')

      {
        href: anchor[0]['href'],
        name: anchor[0].content,
        player_count: plays.css('a')[0].content.to_i
      }
    end.compact
  rescue
    []
  end

  def last_month
    (Date.today - 1.month).beginning_of_month
  end
end
