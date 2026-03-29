# frozen_string_literal: true

module Models
  NormalizedName = Data.define(:value) do
    ORDINALS = {
      "1st" => "1",
      "first" => "1",
      "2nd" => "2",
      "second" => "2",
      "3rd" => "3",
      "third" => "3",
      "4th" => "4",
      "fourth" => "4",
      "5th" => "5",
      "fifth" => "5",
      "6th" => "6",
      "sixth" => "6",
    }.freeze

    ORDINALS_PATTERN = /\b(#{ORDINALS.keys.join("|")})\b/

    def self.from(name)
      normalized = name.to_s
        .unicode_normalize(:nfkd).gsub(/[\u0300-\u036f]/, "")
        .downcase
        .gsub("&", " and ")
        .gsub(/['\u2019]s\b/, "")
        .gsub(/[^\w\s]/, "")
        .gsub(ORDINALS_PATTERN) { ORDINALS[::Regexp.last_match(0)] }
        .gsub(/\bedition\b/, "")
        .gsub(/\b(the|a)\b/, "")
        .squish

      new(value: normalized)
    end

    def to_s = value
    def to_str = value
  end
end
