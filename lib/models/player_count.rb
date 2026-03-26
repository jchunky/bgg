# frozen_string_literal: true

module Models
  PlayerCount = Data.define(:min, :max) do
    def to_s = [min, max].uniq.join("-")
    def range = (min..max)
    def one_player? = max == 1
    def two_player? = max == 2
    def soloable?(coop:) = one_player? || (coop && min == 1)
    def unknown? = min.zero?
  end
end
