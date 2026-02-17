require_relative "../spec_helper"

RSpec.describe Parsers::B2goGame do
  describe ".parse" do
    context "with valid data" do
      let(:data) { ["Test Game (2020)", "Available", "Price: $29.99"] }

      subject(:game) { described_class.parse(data) }

      it "creates a Game object" do
        expect(game).to be_a(Models::Game)
      end

      it "parses the name without year" do
        expect(game.name).to eq("Test Game")
      end

      it "sets b2go to true" do
        expect(game.b2go).to be true
      end

      it "sets b2go_price" do
        expect(game.b2go_price).to eq(30)
      end
    end

    context "with purchase only item" do
      let(:data) { ["Test Game", "Purchase Only", "Price: $19.99"] }

      it "returns nil" do
        expect(described_class.parse(data)).to be_nil
      end
    end

    context "with blank name" do
      let(:data) { ["", "Available", "Price: $29.99"] }

      it "returns nil" do
        expect(described_class.parse(data)).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
