require_relative "../spec_helper"

RSpec.describe Parsers::BgoGame do
  describe "#initialize" do
    context "with 5-part format" do
      let(:data) { "Game Name\n1-4\n60\n8.0\n2.5" }

      subject(:parser) { described_class.new(data) }

      it "parses the name" do
        expect(parser.name).to eq("Game Name")
      end

      it "parses player count" do
        expect(parser.min_player_count).to eq(1)
        expect(parser.max_player_count).to eq(4)
      end

      it "parses playtime" do
        expect(parser.playtime).to eq(60)
      end

      it "parses rating" do
        expect(parser.rating).to eq(8.0)
      end

      it "parses weight" do
        expect(parser.weight).to eq(2.5)
      end

      it "has nil year and offer_count" do
        expect(parser.year).to be_nil
        expect(parser.offer_count).to be_nil
      end
    end

    context "with 6-part format" do
      let(:data) { "Game Name\n2020•5\n2-4\n90\n7.5\n3.0" }

      subject(:parser) { described_class.new(data) }

      it "parses the name" do
        expect(parser.name).to eq("Game Name")
      end

      it "parses year from second part" do
        expect(parser.year).to eq(2020)
      end

      it "parses offer_count from second part" do
        expect(parser.offer_count).to eq(5)
      end

      it "parses player count" do
        expect(parser.min_player_count).to eq(2)
        expect(parser.max_player_count).to eq(4)
      end
    end

    context "with 9-part format" do
      let(:data) { "Game Name\n2021•3\npart3\npart4\n$29.99\n1-6\n120\n8.5\n2.0" }

      subject(:parser) { described_class.new(data) }

      it "parses the name" do
        expect(parser.name).to eq("Game Name")
      end

      it "parses price" do
        expect(parser.price).to eq(29.99)
      end

      it "parses player count" do
        expect(parser.min_player_count).to eq(1)
        expect(parser.max_player_count).to eq(6)
      end

      it "parses playtime" do
        expect(parser.playtime).to eq(120)
      end
    end

    context "with unexpected format" do
      it "raises ArgumentError for 3 parts" do
        expect { described_class.new("a\nb\nc") }.to raise_error(ArgumentError, /Unexpected data format/)
      end
    end
  end

  describe "#to_game" do
    let(:data) { "Test Game\n2020•5\n2-4\n90\n7.5\n3.0" }

    subject(:game) { described_class.new(data).to_game }

    it "creates a Game object" do
      expect(game).to be_a(Models::Game)
    end

    it "sets all attributes on the game" do
      expect(game.name).to eq("Test Game")
      expect(game.year).to eq(2020)
      expect(game.rating).to eq(7.5)
      expect(game.weight).to eq(3.0)
    end

    context "with blank name" do
      let(:data) { "\n2020•5\n2-4\n90\n7.5\n3.0" }

      it "returns nil" do
        expect(game).to be_nil
      end
    end
  end

  describe ".parse" do
    it "returns a Game object for valid data" do
      expect(described_class.parse("Test\n1-2\n60\n8.0\n2.0")).to be_a(Models::Game)
    end

    it "returns nil on error" do
      expect(described_class.parse("invalid")).to be_nil
    end
  end
end
