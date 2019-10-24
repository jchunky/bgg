class Snake
  CATEGORIES = ["Nostalgia", "Dexterity", "Children's", "Cooperative", "Party", "Light Strategy", "Strategy", "Word", "Abstract", "Trivia", "Greatest Hits"]
  FILES = %w[abstract childrens cooperative deck_builder dexterity greatest_hits light_strategy new_arrivals nostalgia party strategy trivia word].map { |f| "input/#{f}.json" }
  SMALL_BOX_LOCATIONS = %w[01C 02C 06C 07D 10C 11A 13C 15C 20B 20C 20D 21B 21E 22D 29B 29C 29D]

  def games
    FILES
      .lazy
      .map { |f| File.read(f) }
      .map { |f| JSON.parse(f) }
      .flat_map do |rows|
        rows.map(&method(:build_game))
      end
      .uniq { |g| g[:key] }
      .force
  end

  def build_game(data)
    name = SnakeName.normalize(Utils.strip_accents(data['title']))

    {
      name: name,
      key: Utils.generate_key(name),
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      location: location(data),
      ts_added: Time.at(data['ts_added'].to_i).strftime("%Y-%m-%d"),
      sell_product: data['sell_product'],
      employees_teachable: (data['employees_teachable'].size rescue 0),
      category: category(data),
      small_box: small_box(data)
    }
  end

  def location(data)
    location = data['shelf_location']
    location.size == 2 ? "0" + location : location
  end

  def small_box(data)
    SMALL_BOX_LOCATIONS.include?(location(data))
  end

  def category(data)
    game_catagories = data['categories'].map { |c| c['name'] }
    CATEGORIES.find { |c| game_catagories.include?(c) }.to_s
  end
end