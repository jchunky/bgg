require_relative "../spec_helper"

RSpec.describe Parsers::SnakesGame do
  describe ".parse" do
    context "with standard location" do
      let(:data) { ["Test Game", "some info", "Located at 5A"] }

      subject(:game) { described_class.parse(data) }

      it "creates a Game object" do
        expect(game).to be_a(Models::Game)
      end

      it "parses the name" do
        expect(game.name).to eq("Test Game")
      end

      it "normalizes location to shelf code" do
        expect(game.snakes_location).to eq("5A")
      end

      it "sets snakes to true" do
        expect(game.snakes).to be true
      end
    end

    context "with New Arrivals location" do
      let(:data) { ["New Game", "info", "Check out our new arrivals section"] }

      it "normalizes to 'New Arrivals'" do
        expect(described_class.parse(data).snakes_location).to eq("New Arrivals")
      end
    end

    context "with Staff Picks location" do
      let(:data) { ["Staff Game", "info", "Featured in staff picks"] }

      it "normalizes to 'Staff Picks'" do
        expect(described_class.parse(data).snakes_location).to eq("Staff Picks")
      end
    end

    context "with unrecognized location" do
      let(:data) { ["Unknown Game", "info", "no valid location here"] }

      subject(:game) { described_class.parse(data) }

      it "returns nil for snakes_location" do
        expect(game.snakes_location).to be_nil
      end

      it "sets snakes to false" do
        expect(game.snakes).to be false
      end
    end

    context "with blank name" do
      let(:data) { ["", "info", "Shelf 1A"] }

      it "returns nil" do
        expect(described_class.parse(data)).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
