require_relative "../spec_helper"

RSpec.describe Parsers::SnakesGame do
  describe "#initialize" do
    context "with standard location" do
      let(:data) { ["Test Game", "some info", "Located at 5A"] }

      subject(:parser) { described_class.new(data) }

      it "parses the name" do
        expect(parser.name).to eq("Test Game")
      end

      it "normalizes location to shelf code" do
        expect(parser.location).to eq("5A")
      end
    end

    context "with New Arrivals location" do
      let(:data) { ["New Game", "info", "Check out our new arrivals section"] }

      subject(:parser) { described_class.new(data) }

      it "normalizes to 'New Arrivals'" do
        expect(parser.location).to eq("New Arrivals")
      end
    end

    context "with Staff Picks location" do
      let(:data) { ["Staff Game", "info", "Featured in staff picks"] }

      subject(:parser) { described_class.new(data) }

      it "normalizes to 'Staff Picks'" do
        expect(parser.location).to eq("Staff Picks")
      end
    end

    context "with unrecognized location" do
      let(:data) { ["Unknown Game", "info", "no valid location here"] }

      subject(:parser) { described_class.new(data) }

      it "returns nil for location" do
        expect(parser.location).to be_nil
      end
    end
  end

  describe "#to_game" do
    context "with valid location" do
      let(:data) { ["Test Game", "info", "Shelf 3B"] }

      subject(:game) { described_class.new(data).to_game }

      it "creates a Game object" do
        expect(game).to be_a(Models::Game)
      end

      it "sets snakes to true" do
        expect(game.snakes).to be true
      end

      it "sets the name" do
        expect(game.name).to eq("Test Game")
      end

      it "sets snakes_location" do
        expect(game.snakes_location).to eq("3B")
      end
    end

    context "with nil location" do
      let(:data) { ["Test Game", "info", "unknown"] }

      subject(:game) { described_class.new(data).to_game }

      it "sets snakes to false" do
        expect(game.snakes).to be false
      end
    end

    context "with blank name" do
      let(:data) { ["", "info", "Shelf 1A"] }

      subject(:game) { described_class.new(data).to_game }

      it "returns nil" do
        expect(game).to be_nil
      end
    end
  end

  describe ".parse" do
    it "returns a Game object for valid data" do
      expect(described_class.parse(["Test", "info", "Shelf 1A"])).to be_a(Models::Game)
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
