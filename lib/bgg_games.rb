class BggGames < Struct.new(:listid, :prefix, :page_count, :object_type, keyword_init: true)
  ITEMS_PER_PAGE = 50

  def games
    (1..page_count)
      .flat_map(&method(:games_for_page))
      .compact
      .uniq(&:key)
  end

  private

  def games_for_page(page)
    url = url_for_page(page)
    Utils.cache_object(url) do
      file = Utils.read_file(url, extension: "json")
      doc = JSON.parse(file)
      games_for_doc(doc, page)
    end
  end

  def url_for_page(page)
    "https://api.geekdo.com/api/geekitem/linkeditems?linkdata_index=boardgame&objectid=#{listid}&objecttype=#{object_type}&showcount=#{ITEMS_PER_PAGE}&sort=rank&pageid=#{page}"
  end

  def games_for_doc(doc, page)
    doc["items"].map.with_index do |item, i|
      Game.new(
        href: href = item["href"],
        key: href,
        name: item["name"],
        "#{prefix}_rank": ((page - 1) * ITEMS_PER_PAGE) + i + 1
      )
    end
  end
end
