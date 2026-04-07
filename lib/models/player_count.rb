# frozen_string_literal: true

module Models
  class PlayerCount < Data.define(:min, :max)
    def to_s = [min, max].uniq.join("-")
    def range = (min..max)
    def soloable?(coop:) = one_player? || (coop && min == 1)
    def unknown? = min.zero?

    def one_player? = max == 1
    def two_player? = max == 2
    def competitive? = max >= 3
  end
end
