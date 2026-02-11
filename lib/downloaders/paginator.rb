module Downloaders
  module Paginator
    def content_for_pages
      (1..).each.with_object([]) do |page, result|
        games = fetch_games_for_page(page)
        result.concat(games)
        return result if search_completed?(games)
      end
    end
  end
end
