class TopChildren < GamepageDownloader
  def url_for_page(page)
    "https://boardgamegeek.com/childrensgames/browse/boardgame/page/#{page}"
  end

  def games_for_doc(doc, _page)
    doc.css(".collection_table")[0].css("tr").map do |row|
      rank, _, title, _, rating = row.css("td")
      next unless rating

      name = Utils.strip_accents(title.css("a")[0].content)

      Game.new(
        href: href = title.css("a")[0]["href"],
        key: href,
        name: name,
        rating: rating.content.to_f,
        year: (title.css("span")[0].content[1..-2].to_i rescue 0),
        children_rank: (rank.css("a")[0]["name"].to_i rescue 0)
      )
    end
  end
end
