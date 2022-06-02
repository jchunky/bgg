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
      _, _, title = row.css("td")
      href = title.css("a")[0]["href"]
      voter_rank = (page - 1) * 100 + i + 1

      Game.new(
        key: href,
        voter_rank: voter_rank
      )
    end
  end
end
