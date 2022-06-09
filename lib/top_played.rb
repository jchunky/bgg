class TopPlayed
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
    end_date = Date.today
    start_date = end_date - 30.days

    "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{start_date}/end/#{end_date}/page/#{page}?sortby=distinctusers"
  end

  def games_for_doc(doc, page)
    doc.css(".forum_table")[1].css("tr").map.with_index do |row, i|
      link = row.css("td")[0]
      next unless link
      anchor = link.css("a")
      name = Utils.strip_accents(anchor[0].content)

      Game.new(
        href: href = anchor[0]["href"],
        key: href,
        name: name,
        play_rank: ((page - 1) * 100) + i + 1
      )
    end
  rescue StandardError
    []
  end
end
