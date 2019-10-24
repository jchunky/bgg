class TopRanked
  def games
    (1..200)
      .lazy
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map(&method(:games_for_doc))
      .uniq { |game| game[:name] }
      .force
  end

  def url_for_page(page)
    "https://boardgamegeek.com/browse/boardgame/page/#{page}"
  end

  def games_for_doc(doc)
    doc.css('.collection_table')[0].css('tr')[1..-1].map.with_index do |row, rank|
      rank, _, title, _, rating, voters, *_, shop = row.css('td')

      {
        href: title.css('a')[0]['href'],
        name: title.css('a')[0].content,
        rank: (rank.css('a')[0]['name'] rescue nil),
        rating: rating.content,
        voters: voters.content,
        ios: shop.to_s.include?("iOS App:"),
        year: (title.css('span')[0].content[1..-2] rescue nil)
      }
    end.compact
  end
end
