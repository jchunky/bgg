# frozen_string_literal: true

module Models
  PublicationAge = Data.define(:year) do
    def years_published
      days_published.to_f / 365
    end

    private

    def days_published
      now = Time.now
      ((now.year - year.to_i) * 365) + now.yday
    end
  end
end
