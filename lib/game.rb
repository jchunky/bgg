class Game
  DEFAULT_VALUES = {
    href: "",
    key: "",
    name: "",
    rating: 0.0,
    weight: 0.0,
  }

  attr_reader :attributes

  def initialize(args)
    @attributes = Hash.new do |hash, key|
      hash[key.to_sym] = DEFAULT_VALUES.fetch(key.to_sym, 0)
    end.merge(args)
  end

  def method_missing(method_name, *args)
    attribute_name = method_name.to_s.chomp("=").to_sym
    if method_name.to_s.end_with?("=")
      attributes[attribute_name] = args.first
    else
      attributes[attribute_name]
    end
  end

  def merge(other)
    Game.new(attributes.merge(other.attributes, &method(:merge_attr)))
  end

  def votes_per_year
    return 0 if year.zero?

    years = (Date.today.year + 1) - year
    years = years.clamp(1..)

    rating_count / years
  end

  def mechanics
    Categories::MECHANICS.map(&:prefix).select { |m| send("#{m}_rank") > 0 }
  end

  def families
    Categories::FAMILIES.map(&:prefix).select { |f| send("#{f}_rank") > 0 }
  end

  Categories::CATEGORIES.each do |category|
    define_method("#{category}?") do
      send("#{category}_rank") > 0
    end
  end

  private

  def merge_attr(_key, oldval, newval)
    oldval.present? && oldval != 0 ? oldval : newval
  end

  concerning :Replays do
    def replays
      @replays ||= begin
        doc = fetch_page_data(tenth_percentile_page)
        rows = doc.css(".forum_table td.lf a")
        if rows.count.zero?
          0
        else
          index = (page_count % 10) / 10.0 * rows.count
          rows[index].content.to_i
        end
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
      @page_count ||= begin
        doc = fetch_page_data(1)
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
    end

    def fetch_page_data(page)
      url = "https://boardgamegeek.com/playstats/thing/#{objectid}/page/#{page}"
      file = Utils.read_file(url, extension: "html")
      Nokogiri::HTML(file)
    end

    def objectid
      href.scan(/\b\d+\b/).first.to_i
    end
  end
end
