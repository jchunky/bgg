require_relative "../spec_helper"

RSpec.describe Parsers::TopPlayedGame do
  describe "#initialize" do
    let(:data) { "Catan 1500 300" }

    subject(:parser) { described_class.new(data) }

    it "parses the name" do
      expect(parser.name).to eq("Catan")
    end

    it "parses the play count" do
      expect(parser.play_count).to eq(1500)
    end

    it "parses the unique users" do
      expect(parser.unique_users).to eq(300)
    end

    context "with multi-word name" do
      let(:data) { "Terraforming Mars 2000 500" }

      subject(:parser) { described_class.new(data) }

      it "parses the full name" do
        expect(parser.name).to eq("Terraforming Mars")
      end

      it "parses the play count" do
        expect(parser.play_count).to eq(2000)
      end

      it "parses the unique users" do
        expect(parser.unique_users).to eq(500)
      end
    end

    context "with invalid format" do
      it "raises ArgumentError" do
        expect { described_class.new("invalid data") }.to raise_error(ArgumentError, /Invalid format/)
      end
    end
  end

  describe "#to_game" do
    let(:data) { "Test Game 100 50" }

    subject(:game) { described_class.new(data).to_game }

    it "creates a Game object" do
      expect(game).to be_a(Models::Game)
    end

    it "sets the name" do
      expect(game.name).to eq("Test Game")
    end

    it "sets play_count" do
      expect(game.play_count).to eq(100)
    end

    it "sets unique_users" do
      expect(game.unique_users).to eq(50)
    end
  end

  describe ".parse" do
    it "returns a Game object for valid data" do
      expect(described_class.parse("Test 100 50")).to be_a(Models::Game)
    end

    it "returns nil on error" do
      expect(described_class.parse("invalid")).to be_nil
    end
  end
end
