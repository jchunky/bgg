class TopVoted
  def games
    (1..10)
      .flat_map(&method(:games_for_page))
      .uniq(&:key)
  end

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_url(url)
      doc = Nokogiri::HTML(file)
      games_for_doc(doc, page)
    end
  end

  def url_for_page(page)
    "https://boardgamegeek.com/browse/boardgame/page/#{page}?sort=numvoters&sortdir=desc"
  end

  def games_for_doc(doc, page)
    doc.css(".collection_table")[0].css("tr").drop(1).map.with_index do |row, i|
      rank, _, title, _, rating, voters, *_, shop = row.css("td")
      name = Utils.strip_accents(title.css("a")[0].content)

      Game.new(
        href: href = title.css("a")[0]["href"],
        name: name,
        rank: (rank.css("a")[0]["name"].to_i rescue 0),
        rating: rating.content.to_f,
        voters: voters.content.to_i,
        key: href,
        year: (title.css("span")[0].content[1..-2].to_i rescue 0),
        voter_rank: (page - 1) * 100 + i + 1
      )
    end
  end
end
