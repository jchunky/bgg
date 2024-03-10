class GamepageDownloader
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
end
