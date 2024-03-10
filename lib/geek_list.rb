class GeekList < Struct.new(:listid, :prefix, :reverse_rank, keyword_init: true)
  def games
    result = (1..8).flat_map(&method(:games_for_page)).compact.uniq(&:key)
    result = result.reverse if reverse_rank
    result.each.with_index do |game, i|
      game["#{prefix}_rank"] = i + 1
    end
  end

  private

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_file(url, extension: "html")
      doc = JSON.parse(file)
      games_for_file(doc, page)
    end
  end

  def url_for_page(page)
    "https://api.geekdo.com/api/listitems?listid=#{listid}&page=#{page}"
  end

  def games_for_file(doc, _page)
    doc["data"].map do |record|
      Game.new(
        href: href = record["item"]["href"],
        key: href,
        name: record["item"]["name"],
        rating: record["stats"]["average"].to_f,
        rank: record["stats"]["rank"].to_i
      )
    end
  end
end
