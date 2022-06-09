class TopThematic
  def games
    (1..10)
      .flat_map(&method(:games_for_page))
      .compact
      .uniq(&:key)
  end

  private

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_url(url)
      doc = Nokogiri::HTML(file)
      games_for_doc(doc, page)
    end
  end

  def url_for_page(page)
    "https://boardgamegeek.com/thematic/browse/boardgame/page/#{page}"
  end

  def games_for_doc(doc, page)
    doc.css(".collection_table")[0].css("tr").map.with_index do |row|
      rank, _, title, _, rating = row.css("td")
      next unless rating
      name = Utils.strip_accents(title.css("a")[0].content)

      Game.new(
        href: href = title.css("a")[0]["href"],
        key: href,
        name: name,
        rating: rating.content.to_f,
        year: (title.css("span")[0].content[1..-2].to_i rescue 0),
        thematic_rank: (rank.css("a")[0]["name"].to_i rescue 0)
      )
    end
  end
end
