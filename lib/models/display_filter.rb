# frozen_string_literal: true

module Models
  class DisplayFilter < SimpleDelegator
    def displayable?
      return false if weight.round(1) > 2.2
      return false if played?
      return false unless b2go?
      return true if learned?
      # return false if campaign?
      return false if banned?
      return false if player_count.min != 1

      # return false unless soloable?
      # return false if price == 0

      true
    end
  end
end
