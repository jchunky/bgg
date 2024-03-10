class TopPlayed
  def games
    (1..10)
      .flat_map(&method(:games_for_page))
      .compact
      .uniq(&:key)
  end

  def prefix
    "play"
  end

  private

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_file(url, extension: "html")
      doc = Nokogiri::HTML(file)
      games_for_doc(doc, page)
    end
  end

  def url_for_page(page)
    end_date = Date.yesterday
    start_date = end_date - 30.days

    "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{start_date}/end/#{end_date}/page/#{page}"
  end

  def games_for_doc(doc, page)
    doc.css(".forum_table")[1].css("tr")
      .select { |row| row.css("td")[0] }
      .map(&method(:game_for_row))
      .sort_by(&:unique_users)
      .reverse
      .each.with_index do |game, i|
        game.play_rank = ((page - 1) * 100) + i + 1
      end
  rescue StandardError
    []
  end

  def game_for_row(row)
    anchor = row.css("td")[0].css("a")[0]
    name = anchor.content
    unique_users = row.css("td")[2].css("a")[0].content.to_i

    Game.new(
      href: href = anchor["href"],
      key: href,
      name:,
      unique_users:
    )
  end
end
