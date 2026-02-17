require_relative "../spec_helper"

RSpec.describe Parsers::SnakesGame do
  describe ".parse" do
    context "with standard location" do
      it "parses game attributes" do
        game = described_class.parse(["Test Game", "some info", "Located at 5A"])

        expect(game).to be_a(Models::Game).and have_attributes(
          name: "Test Game",
          snakes_location: "5A",
          snakes: true
        )
      end
    end

    context "with New Arrivals location" do
      it "normalizes to 'New Arrivals'" do
        expect(described_class.parse(["New Game", "info", "Check out our new arrivals section"]).snakes_location).to eq("New Arrivals")
      end
    end

    context "with Staff Picks location" do
      it "normalizes to 'Staff Picks'" do
        expect(described_class.parse(["Staff Game", "info", "Featured in staff picks"]).snakes_location).to eq("Staff Picks")
      end
    end

    context "with unrecognized location" do
      it "parses game with nil location" do
        game = described_class.parse(["Unknown Game", "info", "no valid location here"])

        expect(game).to have_attributes(
          snakes_location: nil,
          snakes: false
        )
      end
    end

    context "with blank name" do
      it "returns nil" do
        expect(described_class.parse(["", "info", "Shelf 1A"])).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
