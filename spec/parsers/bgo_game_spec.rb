require_relative "../spec_helper"

RSpec.describe Parsers::BgoGame do
  describe ".parse" do
    context "with 5-part format" do
      let(:data) { "Game Name\n1-4\n60\n8.0\n2.5" }

      subject(:game) { described_class.parse(data) }

      it "parses the name" do
        expect(game.name).to eq("Game Name")
      end

      it "parses player count" do
        expect(game.min_player_count).to eq(1)
        expect(game.max_player_count).to eq(4)
      end

      it "parses playtime" do
        expect(game.playtime).to eq(60)
      end

      it "parses rating" do
        expect(game.rating).to eq(8.0)
      end

      it "parses weight" do
        expect(game.weight).to eq(2.5)
      end

      it "has nil year and offer_count" do
        expect(game.year).to be_nil
        expect(game.offer_count).to be_nil
      end
    end

    context "with 6-part format" do
      let(:data) { "Game Name\n2020•5\n2-4\n90\n7.5\n3.0" }

      subject(:game) { described_class.parse(data) }

      it "parses the name" do
        expect(game.name).to eq("Game Name")
      end

      it "parses year from second part" do
        expect(game.year).to eq(2020)
      end

      it "parses offer_count from second part" do
        expect(game.offer_count).to eq(5)
      end

      it "parses player count" do
        expect(game.min_player_count).to eq(2)
        expect(game.max_player_count).to eq(4)
      end
    end

    context "with 9-part format" do
      let(:data) { "Game Name\n2021•3\npart3\npart4\n$29.99\n1-6\n120\n8.5\n2.0" }

      subject(:game) { described_class.parse(data) }

      it "parses the name" do
        expect(game.name).to eq("Game Name")
      end

      it "parses price" do
        expect(game.price).to eq(29.99)
      end

      it "parses player count" do
        expect(game.min_player_count).to eq(1)
        expect(game.max_player_count).to eq(6)
      end

      it "parses playtime" do
        expect(game.playtime).to eq(120)
      end
    end

    context "with unexpected format" do
      it "returns nil for 3 parts" do
        expect(described_class.parse("a\nb\nc")).to be_nil
      end
    end

    context "with blank name" do
      let(:data) { "\n2020•5\n2-4\n90\n7.5\n3.0" }

      it "returns nil" do
        expect(described_class.parse(data)).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse("invalid")).to be_nil
    end
  end
end
