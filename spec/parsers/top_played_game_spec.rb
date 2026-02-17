require_relative "../spec_helper"

RSpec.describe Parsers::TopPlayedGame do
  describe ".parse" do
    context "with valid data" do
      let(:data) { "Catan 1500 300" }

      subject(:game) { described_class.parse(data) }

      it "creates a Game object" do
        expect(game).to be_a(Models::Game)
      end

      it "parses the name" do
        expect(game.name).to eq("Catan")
      end

      it "parses play_count" do
        expect(game.play_count).to eq(1500)
      end

      it "parses unique_users" do
        expect(game.unique_users).to eq(300)
      end
    end

    context "with multi-word name" do
      let(:data) { "Terraforming Mars 2000 500" }

      subject(:game) { described_class.parse(data) }

      it "parses the full name" do
        expect(game.name).to eq("Terraforming Mars")
      end

      it "parses play_count" do
        expect(game.play_count).to eq(2000)
      end

      it "parses unique_users" do
        expect(game.unique_users).to eq(500)
      end
    end

    context "with invalid format" do
      it "returns nil" do
        expect(described_class.parse("invalid data")).to be_nil
      end
    end

    it "returns nil on error" do
      expect(described_class.parse(nil)).to be_nil
    end
  end
end
