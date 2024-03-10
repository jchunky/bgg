class TopBga
  def prefix
    'bga'
  end

  def games
    (1..90)
      .flat_map(&method(:games_for_page))
      .compact
      .uniq(&:key)
  end

  private

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_json(url)
      doc = JSON.parse(file)
      games_for_doc(doc, page)
    end
  end

  def url_for_page(page)
    "https://api.geekdo.com/api/geekitem/linkeditems?ajax=1&linkdata_index=boardgame&nosession=1&objectid=70360&objecttype=family&showcount=10&sort=rank&subtype=boardgamefamily&pageid=#{page}"
  end

  def games_for_doc(doc, page)
    doc["items"].map.with_index do |item, i|
      Game.new(
        href: href = item["href"],
        key: href,
        name: Utils.strip_accents(item["name"]),
        bga_rank: ((page - 1) * 10) + i + 1
      )
    end
  rescue StandardError
    []
  end
end
