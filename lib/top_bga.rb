class TopBga
  ITEMS_PER_PAGE = 50
  OBJECTID = 70360

  def prefix
    'bga'
  end

  def listid
    OBJECTID
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
    "https://api.geekdo.com/api/geekitem/linkeditems?ajax=1&linkdata_index=boardgame&nosession=1&objectid=#{OBJECTID}&objecttype=family&showcount=#{ITEMS_PER_PAGE}&sort=rank&subtype=boardgamefamily&pageid=#{page}"
  end

  def games_for_doc(doc, page)
    doc["items"].map.with_index do |item, i|
      Game.new(
        href: href = item["href"],
        key: href,
        name: Utils.strip_accents(item["name"]),
        bga_rank: ((page - 1) * ITEMS_PER_PAGE) + i + 1
      )
    end
  end
end
