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

  private

  def merge_attr(attr, other)
    value = send(attr)
    other_value = other.send(attr)

    value.present? && value != 0 ? value : other_value
  end
end
