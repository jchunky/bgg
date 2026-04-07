# frozen_string_literal: true

module Config
  module Classifications
    Classification = Data.define(:prefix, :listid, :items_per_page, :object_type, :visible) do
      def self.build(prefix:, listid:, items_per_page:, object_type:, visible: true)
        new(prefix:, listid:, items_per_page:, object_type:, visible:)
      end
    end

    CATEGORIES = [
      # category
      Classification.build(prefix: :dexterity, listid: 1032, items_per_page: 50, object_type: "property"),

      # family
      Classification.build(prefix: :digital_hybrid, listid: 41489, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :werewolf, listid: 2989, items_per_page: 50, object_type: "family"),

      # mechanism
      Classification.build(prefix: :campaign, listid: 2822, items_per_page: 50, object_type: "property"),
      Classification.build(prefix: :coop, listid: 2023, items_per_page: 50, object_type: "property", visible: false),
      Classification.build(prefix: :realtime, listid: 2831, items_per_page: 50, object_type: "property"),
      Classification.build(prefix: :traitor, listid: 2814, items_per_page: 50, object_type: "property"),
    ].freeze

    SUBDOMAINS = [
      Classification.build(prefix: :abstract, listid: 4666, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :ccg, listid: 4667, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :child, listid: 4665, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :family, listid: 5499, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :party, listid: 5498, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :strategy, listid: 5497, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :thematic, listid: 5496, items_per_page: 50, object_type: "family"),
      Classification.build(prefix: :war, listid: 4664, items_per_page: 50, object_type: "family"),
    ].freeze
  end
end
