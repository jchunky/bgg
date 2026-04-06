# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Models::Game do
  describe "#initialize" do
    it "creates a game with given attributes" do
      game = described_class.new(name: "Test Game", rating: 8.0)
      expect(game.name).to eq("Test Game")
      expect(game.rating).to eq(8.0)
    end

    it "defaults missing attributes to 0" do
      game = described_class.new(name: "Test")
      expect(game.weight).to eq(0)
    end
  end

  describe "#key" do
    it "returns a NormalizedName" do
      game = described_class.new(name: "Test Game")
      expect(game.key).to be_a(Models::NormalizedName)
    end

    it "matches games with variant names" do
      game1 = described_class.new(name: "A Game of Cat & Mouth")
      game2 = described_class.new(name: "A Game of Cat and Mouth")
      expect(game1.key).to eq(game2.key)
    end

    it "resolves aliased names for matching" do
      allow(Config::GameLists).to receive(:name_aliases)
        .and_return("B2GO Title" => "BGG Title")

      b2go_game = described_class.new(name: "B2GO Title")
      bgg_game = described_class.new(name: "BGG Title")
      expect(b2go_game.key).to eq(bgg_game.key)
    end
  end

  describe "#merge" do
    it "prefers other's non-null values over self's" do
      game1 = described_class.new(name: "Test", rating: 8.0, weight: 0)
      game2 = described_class.new(name: "Test", rating: 7.0, weight: 2.5)

      merged = game1.merge(game2)

      expect(merged.name).to eq("Test")
      expect(merged.rating).to eq(7.0) # other's non-null value takes precedence
      expect(merged.weight).to eq(2.5) # other's value used since self's is zero (null)
    end

    it "keeps other's non-null value when both games have a value" do
      game1 = described_class.new(name: "Test", rating: 8.0)
      game2 = described_class.new(name: "Test", rating: 7.0)

      merged = game1.merge(game2)

      expect(merged.rating).to eq(7.0)
    end

    it "falls back to self's value when other's value is null (zero)" do
      game1 = described_class.new(name: "Test", weight: 2.5)
      game2 = described_class.new(name: "Test", weight: 0)

      merged = game1.merge(game2)

      expect(merged.weight).to eq(2.5)
    end

    it "returns a new Game object" do
      game1 = described_class.new(name: "Test", rating: 8.0)
      game2 = described_class.new(name: "Test", rating: 7.0)

      merged = game1.merge(game2)
      expect(merged).to be_a(described_class)
      expect(merged).not_to eq(game1)
      expect(merged).not_to eq(game2)
    end
  end

  describe "dynamic attribute access" do
    let(:game) { described_class.new(name: "Test", coop_rank: 5) }

    it "returns attribute value" do
      expect(game.name).to eq("Test")
    end

    it "allows setting attributes" do
      game.rating = 8.5
      expect(game.rating).to eq(8.5)
    end

    it "returns true for predicate if rank is positive" do
      expect(game.coop?).to be true
    end

    it "returns false for predicate if rank is zero" do
      game = described_class.new(name: "Test", coop_rank: 0)
      expect(game.coop?).to be false
    end

    it "responds to dynamic attribute methods" do
      expect(game.respond_to?(:name)).to be true
      expect(game.respond_to?(:rating=)).to be true
      expect(game.respond_to?(:coop?)).to be true
    end
  end

  describe "#player_count" do
    it "returns a PlayerCount value object" do
      game = described_class.new(minplayers: 2, maxplayers: 4)
      expect(game.player_count).to eq(Models::PlayerCount.new(min: 2, max: 4))
    end

    it "converts string values to integers" do
      game = described_class.new(minplayers: "1", maxplayers: "4")
      expect(game.player_count).to eq(Models::PlayerCount.new(min: 1, max: 4))
    end
  end

  describe "#one_player?" do
    it "returns true for solo games" do
      game = described_class.new(minplayers: 1, maxplayers: 1)
      expect(game.one_player?).to be true
    end

    it "returns false for multiplayer games" do
      game = described_class.new(minplayers: 1, maxplayers: 4)
      expect(game.one_player?).to be false
    end
  end

  describe "#two_player?" do
    it "returns true for 2 player max games" do
      game = described_class.new(minplayers: 1, maxplayers: 2)
      expect(game.two_player?).to be true
    end

    it "returns false for other games" do
      game = described_class.new(minplayers: 1, maxplayers: 4)
      expect(game.two_player?).to be false
    end
  end

  describe "#soloable?" do
    it "returns true for solo games" do
      game = described_class.new(minplayers: 1, maxplayers: 1)
      expect(game.soloable?).to be true
    end

    it "returns true for coop games starting at 1 player" do
      game = described_class.new(coop_rank: 1, minplayers: 1, maxplayers: 4)
      expect(game.soloable?).to be true
    end

    it "returns false for non-coop multiplayer games" do
      game = described_class.new(minplayers: 2, maxplayers: 4)
      expect(game.soloable?).to be false
    end
  end

  describe "#price" do
    it "rounds price to nearest integer" do
      game = described_class.new(bgp_price: 39.50)
      expect(game.price).to eq(40)
    end
  end

  describe "#votes_per_year" do
    it "calculates votes per year based on rating count and year" do
      game = described_class.new(rating_count: 1000, year: Time.now.year - 2)
      expect(game.votes_per_year).to be_between(300, 500)
    end
  end

  describe "#crowdfunded?" do
    it "returns true for kickstarter games" do
      game = described_class.new(kickstarter_rank: 1)
      expect(game.crowdfunded?).to be true
    end

    it "returns true for gamefound games" do
      game = described_class.new(gamefound_rank: 1)
      expect(game.crowdfunded?).to be true
    end

    it "returns true for backerkit games" do
      game = described_class.new(backerkit_rank: 1)
      expect(game.crowdfunded?).to be true
    end

    it "returns false for non-crowdfunded games" do
      game = described_class.new(name: "Test")
      expect(game.crowdfunded?).to be false
    end
  end

  describe "#competitive?" do
    it "returns true when group is competitive" do
      game = described_class.new(minplayers: 2, maxplayers: 4)
      expect(game.competitive?).to be true
    end

    it "returns false for coop games" do
      game = described_class.new(coop_rank: 1)
      expect(game.competitive?).to be false
    end
  end

  describe "#play_rank?" do
    it "returns true when play_rank is positive" do
      game = described_class.new(play_rank: 5)
      expect(game.play_rank?).to be true
    end

    it "returns false when play_rank is zero" do
      game = described_class.new(play_rank: 0)
      expect(game.play_rank?).to be false
    end
  end
end
