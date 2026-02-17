require_relative "../spec_helper"

RSpec.describe Parsers::BgbGame do
  describe ".parse" do
    context "with valid data" do
      let(:data) do
        <<~DATA
          line1
          line2
          Test Game Name
          line4
          1-4
          60
          8.5
          2.5
          Regular
          $49.99
        DATA
      end

      subject(:game) { described_class.parse(data) }

      it "creates a Game object" do
        expect(game).to be_a(Models::Game)
      end

      it "parses the name" do
        expect(game.name).to eq("Test Game Name")
      end

      it "parses player count range" do
        expect(game.min_player_count).to eq(1)
        expect(game.max_player_count).to eq(4)
      end

      it "parses playtime" do
        expect(game.playtime).to eq(60)
      end

      it "parses rating" do
        expect(game.rating).to eq(8.5)
      end

      it "parses weight" do
        expect(game.weight).to eq(2.5)
      end

      it "sets bgb to true" do
        expect(game.bgb).to be true
      end

      it "parses preorder status" do
        expect(game.preorder).to be false
      end

      it "parses bgb_price" do
        expect(game.bgb_price).to eq(49.99)
      end
    end

    context "with preorder item" do
      let(:data) do
        <<~DATA
          line1
          line2
          Pre-Order Game
          line4
          2-4
          90
          7.0
          3.0
          *PRE-ORDER*
          $59.99
        DATA
      end

      it "parses preorder as true" do
        expect(described_class.parse(data).preorder).to be true
      end
    end

    context "with blank name" do
      let(:data) do
        <<~DATA
          line1
          line2

          line4
          1-4
          60
          8.5
          2.5
          Regular
          $49.99
        DATA
      end

      it "returns nil" do
        expect(described_class.parse(data)).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
