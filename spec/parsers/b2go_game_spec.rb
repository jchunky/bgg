require_relative "../spec_helper"

RSpec.describe Parsers::B2goGame do
  describe "#initialize" do
    let(:data) { ["Test Game (2020)", "Some Details", "Price: $29.99"] }

    subject(:parser) { described_class.new(data) }

    it "parses the name without year" do
      expect(parser.name).to eq("Test Game")
    end

    it "parses the price" do
      expect(parser.price).to eq(30)
    end
  end

  describe "#to_game" do
    context "with valid data" do
      let(:data) { ["Test Game (2020)", "Available", "Price: $29.99"] }

      subject(:game) { described_class.new(data).to_game }

      it "creates a Game object" do
        expect(game).to be_a(Models::Game)
      end

      it "sets b2go to true" do
        expect(game.b2go).to be true
      end

      it "sets the name" do
        expect(game.name).to eq("Test Game")
      end

      it "sets b2go_price" do
        expect(game.b2go_price).to eq(30)
      end
    end

    context "with purchase only item" do
      let(:data) { ["Test Game", "Purchase Only", "Price: $19.99"] }

      subject(:game) { described_class.new(data).to_game }

      it "returns nil" do
        expect(game).to be_nil
      end
    end

    context "with blank name" do
      let(:data) { ["", "Available", "Price: $29.99"] }

      it "returns nil via parse (handles error)" do
        expect(described_class.parse(data)).to be_nil
      end
    end
  end

  describe ".parse" do
    it "returns a Game object for valid data" do
      expect(described_class.parse(["Test", "Available", "Price: $10"])).to be_a(Models::Game)
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
