class GameSearch
  attr_reader :listid, :prefix, :search_criteria

  def initialize(prefix:, search_criteria:, listid: nil)
    @prefix = prefix
    @search_criteria = search_criteria
    @listid = listid
  end

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
      file = Utils.read_file(url, extension: "html")
      doc = Nokogiri::HTML(file)
      games_for_doc(doc, page)
    end
  end

  def url_for_page(page)
    "https://boardgamegeek.com/search/boardgame/page/#{page}?advsearch=1&#{search_criteria}"
  end

  def games_for_doc(doc, page)
    doc.css(".collection_table")[0].css("tr")
      .select { |row| row.css("td")[4] }
      .map.with_index do |row, i|
        rank, _, title, _, rating, rating_count = row.css("td")
        name = title.css("a")[0].content

        Game.new(
          href: href = title.css("a")[0]["href"],
          key: href,
          name:,
          rating: rating.content.to_f,
          rating_count: rating_count.content.to_i,
          year: (title.css("span")[0].content[1..-2].to_i rescue 0),
          rank: (rank.css("a")[0]["name"].to_i rescue 0),
          "#{prefix}_rank": ((page - 1) * 100) + i + 1
        )
      end
  rescue StandardError
    []
  end
end
