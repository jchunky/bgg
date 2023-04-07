class TopCouples
  def games
    (1..8)
      .flat_map(&method(:games_for_page))
      .compact
      .uniq(&:key)
  end

  private

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_url(url)
      games_for_file(file, page)
    end
  end

  def url_for_page(page)
    "https://api.geekdo.com/api/listitems?page=#{page}&listid=307302"
  end

  def games_for_file(file, page)
    JSON.parse(file)["data"].map.with_index do |record, i|
      Game.new(
        href: href = record["item"]["href"],
        key: href,
        name: Utils.strip_accents(record["item"]["name"]),
        rating: record["stats"]["average"].to_f,
        rank: record["stats"]["rank"].to_i,
        couples_rank: (page - 1) * 25 + i + 1
      )
    end
  end
end
