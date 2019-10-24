class TopRanked
  def games
    (1..200)
      .lazy
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map(&method(:games_for_doc))
      .uniq { |g| g[:key] }
      .force
  end

  def url_for_page(page)
    "https://boardgamegeek.com/browse/boardgame/page/#{page}"
  end

  def games_for_doc(doc)
    doc.css('.collection_table')[0].css('tr').drop(1).map.with_index do |row, rank|
      rank, _, title, _, rating, voters, *_, shop = row.css('td')

      rank = rank.css('a')[0]['name'] rescue nil
      href = title.css('a')[0]['href']
      name = Utils.strip_accents(title.css('a')[0].content)
      rating = rating.content
      voters = voters.content
      ios = shop.to_s.include?("iOS App:")
      year = title.css('span')[0].content[1..-2] rescue nil

      {
        href: href,
        name: name,
        rank: rank,
        rating: rating,
        voters: voters,
        key: Utils.generate_key(name),
        ios: ios,
        year: year
      }
    end.compact
  end
end
