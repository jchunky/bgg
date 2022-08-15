class TopVoted < GamepageDownloader
  def url_for_page(page)
    "https://boardgamegeek.com/browse/boardgame/page/#{page}?sort=numvoters&sortdir=desc"
  end

  def games_for_doc(doc, page)
    doc.css(".collection_table")[0].css("tr")
      .select { |row| row.css("td")[4] }
      .map.with_index do |row, i|
        rank, _, title, _, rating = row.css("td")
        name = Utils.strip_accents(title.css("a")[0].content)

        Game.new(
          href: href = title.css("a")[0]["href"],
          key: href,
          name: name,
          rating: rating.content.to_f,
          year: (title.css("span")[0].content[1..-2].to_i rescue 0),
          rank: (rank.css("a")[0]["name"].to_i rescue 0),
          vote_rank: ((page - 1) * 100) + i + 1
        )
      end
  end
end
