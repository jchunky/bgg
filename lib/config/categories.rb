# frozen_string_literal: true

module Config
  module Categories
    CATEGORIES = [
      # category
      [:dexterity, 1032, 50, "property"],

      # family
      [:digital_hybrid, 41489, 50, "family"],
      [:werewolf, 2989, 50, "family"],

      # mechanism
      [:campaign, 2822, 50, "property"],
      [:coop, 2023, 50, "property", false],
      [:realtime, 2831, 50, "property"],
      [:traitor, 2814, 50, "property"],
    ].freeze

    SUBDOMAINS = [
      [:abstract, 4666, 50],
      [:ccg, 4667, 50],
      [:child, 4665, 50],
      [:family, 5499, 50],
      [:party, 5498, 50],
      [:strategy, 5497, 50],
      [:thematic, 5496, 50],
      [:war, 4664, 50],
    ].freeze
  end
end
