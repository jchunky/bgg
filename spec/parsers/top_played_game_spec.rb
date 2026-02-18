# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Parsers::TopPlayedGame do
  describe ".parse" do
    context "with valid data" do
      it "parses game attributes" do
        game = described_class.parse("Catan 1500 300")

        expect(game).to be_a(Models::Game).and have_attributes(
          name: "Catan",
          play_count: 1500,
          unique_users: 300,
        )
      end
    end

    context "with multi-word name" do
      it "parses game attributes" do
        game = described_class.parse("Terraforming Mars 2000 500")

        expect(game).to have_attributes(
          name: "Terraforming Mars",
          play_count: 2000,
          unique_users: 500,
        )
      end
    end

    context "with invalid format" do
      it "returns nil" do
        expect(described_class.parse("invalid data")).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
