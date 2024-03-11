require_relative "game_fields"

class Game < Struct.new(*GameFields::FIELDS.keys, keyword_init: true)
  include Categories
  include GameFields

  def initialize(args)
    super(FIELDS.to_h { |attr, default| [attr, args.fetch(attr, default)] })
  end

  def merge(other)
    Game.new(members.to_h { |attr| [attr, merge_attr(attr, other)] })
  end

  def votes_per_year
    return 0 if year.zero?

    years = (Date.today.year + 1) - year
    years = 1 if years < 1

    rating_count / years
  end

  def mechanics
    MECHANICS.map(&:prefix).select { |m| send("#{m}_rank") > 0 }
  end

  def families
    FAMILIES.map(&:prefix).select { |f| send("#{f}_rank") > 0 }
  end

  Categories::CATEGORIES.each do |category|
    define_method("#{category}?") do
      send("#{category}_rank") > 0
    end
  end

  def replays
    url = "https://boardgamegeek.com/playstats/thing/#{objectid}/page/#{tenth_percentile_page}"
    file = Utils.read_file(url, extension: "html")
    doc = Nokogiri::HTML(file)
    rows = doc.css(".forum_table td.lf a")
    if rows.count.zero?
      0
    else
      index = (page_count % 10) / 10.0 * rows.count
      rows[index].content.to_i
    end
  end

  private

  def tenth_percentile_page
    if page_count >= 10 && page_count % 10 == 0
      (page_count / 10) + 1
    else
      (page_count / 10.0).ceil
    end
  end

  def page_count
    url = "https://boardgamegeek.com/playstats/thing/#{objectid}/page/1"
    file = Utils.read_file(url, extension: "html")
    doc = Nokogiri::HTML(file)
    last_page_anchor = doc.css('#maincontent p a[title="last page"]')
    pagination_anchors = doc.css("#maincontent p a")
    if last_page_anchor.count >= 1
      last_page_anchor.first.content.scan(/\d+/).first.to_i
    elsif pagination_anchors.count >= 2
      pagination_anchors[-2].content.to_i
    else
      1
    end
  end

  def objectid
    href.scan(/\b\d+\b/).first.to_i
  end

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
