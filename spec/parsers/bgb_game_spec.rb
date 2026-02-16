require_relative "../spec_helper"

RSpec.describe Parsers::BgbGame do
  describe "#initialize" do
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

    subject(:parser) { described_class.new(data) }

    it "parses the name" do
      expect(parser.name).to eq("Test Game Name")
    end

    it "parses player count range" do
      expect(parser.min_player_count).to eq(1)
      expect(parser.max_player_count).to eq(4)
    end

    it "parses playtime" do
      expect(parser.playtime).to eq(60)
    end

    it "parses rating" do
      expect(parser.rating).to eq(8.5)
    end

    it "parses weight" do
      expect(parser.weight).to eq(2.5)
    end

    it "parses preorder status" do
      expect(parser.preorder).to be false
    end

    it "parses price" do
      expect(parser.price).to eq(49.99)
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
        expect(parser.preorder).to be true
      end
    end
  end

  describe "#to_game" do
    let(:data) do
      <<~DATA
        line1
        line2
        Test Game
        line4
        1-4
        60
        8.5
        2.5
        Regular
        $49.99
      DATA
    end

    subject(:game) { described_class.new(data).to_game }

    it "creates a Game object" do
      expect(game).to be_a(Models::Game)
    end

    it "sets bgb to true" do
      expect(game.bgb).to be true
    end

    it "sets name on the game" do
      expect(game.name).to eq("Test Game")
    end

    it "sets bgb_price on the game" do
      expect(game.bgb_price).to eq(49.99)
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
        expect(game).to be_nil
      end
    end
  end

  describe ".parse" do
    let(:data) do
      <<~DATA
        line1
        line2
        Test Game
        line4
        1-4
        60
        8.5
        2.5
        Regular
        $49.99
      DATA
    end

    it "returns a Game object" do
      expect(described_class.parse(data)).to be_a(Models::Game)
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
