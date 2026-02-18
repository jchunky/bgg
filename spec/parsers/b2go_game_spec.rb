# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Parsers::B2goGame do
  describe ".parse" do
    context "with valid data" do
      it "parses game attributes" do
        game = described_class.parse(["Test Game (2020)", "Available", "Price: $29.99"])

        expect(game).to be_a(Models::Game).and have_attributes(
          name: "Test Game",
          b2go: true,
          b2go_price: 30,
        )
      end
    end

    context "with purchase only item" do
      it "returns nil" do
        expect(described_class.parse(["Test Game", "Purchase Only", "Price: $19.99"])).to be_nil
      end
    end

    context "with blank name" do
      it "returns nil" do
        expect(described_class.parse(["", "Available", "Price: $29.99"])).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
