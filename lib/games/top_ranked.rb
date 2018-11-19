class TopRanked
  def games
    (1..200)
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map { |doc| games_for_doc(doc) }
      .uniq { |game| game.key }
  end

  def url_for_page(page)
    "https://boardgamegeek.com/browse/boardgame/page/#{page}"
  end

  def games_for_doc(doc)
    doc.css('.collection_table')[0].css('tr')[1..-1].map.with_index do |row, rank|
      rank, _, title, _, rating, voters, *_, shop = row.css('td')

      rank = rank.css('a')[0]['name'] rescue nil
      href = title.css('a')[0]['href']
      name = title.css('a')[0].content
      rating = rating.content
      voters = voters.content
      ios = shop.to_s.include?("iOS App:")

      OpenStruct.new(
        href: href,
        name: name,
        rank: rank,
        rating: rating,
        voters: voters,
        key: Utils.generate_key(name),
        ios: ios
      )
    end.compact
  end
end