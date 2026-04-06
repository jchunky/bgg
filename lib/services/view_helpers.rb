# frozen_string_literal: true

module Services
  module ViewHelpers
    def int(value)
      value.to_i.zero? ? "" : value
    end

    def float(value, decimals: 1)
      value.to_f.zero? ? "" : format("%0.#{decimals}f", value)
    end

  end
end
