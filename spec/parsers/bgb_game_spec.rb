require_relative "../spec_helper"

RSpec.describe Parsers::BgbGame do
  describe ".parse" do
    context "with valid data" do
      it "parses game attributes" do
        data = "line1\nline2\nTest Game Name\nline4\n1-4\n60\n8.5\n2.5\nRegular\n$49.99\n"

        game = described_class.parse(data)

        expect(game).to be_a(Models::Game).and have_attributes(
          name: "Test Game Name",
          min_player_count: 1,
          max_player_count: 4,
          playtime: 60,
          rating: 8.5,
          weight: 2.5,
          bgb: true,
          preorder: false,
          bgb_price: 49.99
        )
      end
    end

    context "with preorder item" do
      it "parses preorder as true" do
        data = "line1\nline2\nPre-Order Game\nline4\n2-4\n90\n7.0\n3.0\n*PRE-ORDER*\n$59.99\n"

        expect(described_class.parse(data).preorder).to be true
      end
    end

    context "with blank name" do
      it "returns nil" do
        data = "line1\nline2\n\nline4\n1-4\n60\n8.5\n2.5\nRegular\n$49.99\n"

        expect(described_class.parse(data)).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
