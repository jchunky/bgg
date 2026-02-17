require_relative "../spec_helper"

RSpec.describe Parsers::BgoGame do
  describe ".parse" do
    context "with 5-part format" do
      it "parses game attributes" do
        game = described_class.parse("Game Name\n1-4\n60\n8.0\n2.5")

        expect(game).to be_a(Models::Game).and have_attributes(
          name: "Game Name",
          min_player_count: 1,
          max_player_count: 4,
          playtime: 60,
          rating: 8.0,
          weight: 2.5,
          year: nil,
          offer_count: nil
        )
      end
    end

    context "with 6-part format" do
      it "parses game attributes" do
        game = described_class.parse("Game Name\n2020•5\n2-4\n90\n7.5\n3.0")

        expect(game).to have_attributes(
          name: "Game Name",
          year: 2020,
          offer_count: 5,
          min_player_count: 2,
          max_player_count: 4
        )
      end
    end

    context "with 9-part format" do
      it "parses game attributes" do
        game = described_class.parse("Game Name\n2021•3\npart3\npart4\n$29.99\n1-6\n120\n8.5\n2.0")

        expect(game).to have_attributes(
          name: "Game Name",
          price: 29.99,
          min_player_count: 1,
          max_player_count: 6,
          playtime: 120
        )
      end
    end

    context "with unexpected format" do
      it "returns nil" do
        expect(described_class.parse("a\nb\nc")).to be_nil
      end
    end

    context "with blank name" do
      it "returns nil" do
        expect(described_class.parse("\n2020•5\n2-4\n90\n7.5\n3.0")).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse("invalid")).to be_nil
    end
  end
end
