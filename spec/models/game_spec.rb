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
    it "normalizes name to lowercase without special characters" do
      game = described_class.new(name: "Test: The Game!")
      expect(game.key).to eq("test the game")
    end

    it "squishes whitespace" do
      game = described_class.new(name: "Test   Game")
      expect(game.key).to eq("test game")
    end
  end

  describe "#merge" do
    it "keeps self's non-null values and fills in nulls from other" do
      game1 = described_class.new(name: "Test", rating: 8.0, weight: 0)
      game2 = described_class.new(name: "Test", rating: 7.0, weight: 2.5)

      merged = game1.merge(game2)

      expect(merged.name).to eq("Test")
      expect(merged.rating).to eq(8.0)  # self's non-null value preserved
      expect(merged.weight).to eq(2.5)  # other's value used since self's is zero (null)
    end

    it "keeps self's non-null value when both games have a value" do
      game1 = described_class.new(name: "Test", rating: 8.0)
      game2 = described_class.new(name: "Test", rating: 7.0)

      merged = game1.merge(game2)

      expect(merged.rating).to eq(8.0)
    end

    it "falls back to other's value when self's value is null (zero)" do
      game1 = described_class.new(name: "Test", weight: 0)
      game2 = described_class.new(name: "Test", weight: 2.5)

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
  end

  describe "#player_count" do
    it "returns range when min and max differ" do
      game = described_class.new(min_player_count: 2, max_player_count: 4)
      expect(game.player_count).to eq("2-4")
    end

    it "returns single number when min equals max" do
      game = described_class.new(min_player_count: 1, max_player_count: 1)
      expect(game.player_count).to eq("1")
    end
  end

  describe "#player_count_range" do
    it "returns a range from min to max" do
      game = described_class.new(min_player_count: 1, max_player_count: 4)
      expect(game.player_count_range).to eq(1..4)
    end
  end

  describe "#group" do
    it "returns 'party' for party games" do
      game = described_class.new(party_rank: 1)
      expect(game.group).to eq("party")
    end

    it "returns 'coop' for coop games" do
      game = described_class.new(coop_rank: 1)
      expect(game.group).to eq("coop")
    end

    it "returns '1-player' for solo games" do
      game = described_class.new(min_player_count: 1, max_player_count: 1)
      expect(game.group).to eq("1-player")
    end

    it "returns '2-player' for two player games" do
      game = described_class.new(min_player_count: 2, max_player_count: 2)
      expect(game.group).to eq("2-player")
    end

    it "returns 'competitive' for other games" do
      game = described_class.new(min_player_count: 2, max_player_count: 4)
      expect(game.group).to eq("competitive")
    end
  end

  describe "#one_player?" do
    it "returns true for solo games" do
      game = described_class.new(max_player_count: 1)
      expect(game.one_player?).to be true
    end

    it "returns false for multiplayer games" do
      game = described_class.new(max_player_count: 4)
      expect(game.one_player?).to be false
    end
  end

  describe "#two_player?" do
    it "returns true for 2 player max games" do
      game = described_class.new(max_player_count: 2)
      expect(game.two_player?).to be true
    end

    it "returns false for other games" do
      game = described_class.new(max_player_count: 4)
      expect(game.two_player?).to be false
    end
  end

  describe "#soloable?" do
    it "returns true for solo games" do
      game = described_class.new(max_player_count: 1)
      expect(game.soloable?).to be true
    end

    it "returns true for coop games starting at 1 player" do
      game = described_class.new(coop_rank: 1, min_player_count: 1, max_player_count: 4)
      expect(game.soloable?).to be true
    end

    it "returns false for non-coop multiplayer games" do
      game = described_class.new(min_player_count: 2, max_player_count: 4)
      expect(game.soloable?).to be false
    end
  end

  describe "#normalized_price" do
    it "prefers bgb_price when available" do
      game = described_class.new(bgb_price: 49.99, price: 39.99)
      expect(game.normalized_price).to eq(50)
    end

    it "falls back to price when bgb_price is 0" do
      game = described_class.new(bgb_price: 0, price: 39.50)
      expect(game.normalized_price).to eq(40)
    end
  end

  describe "#votes_per_year" do
    it "calculates votes per year based on rating count and year" do
      game = described_class.new(rating_count: 1000, year: Time.now.year - 2)
      votes = game.votes_per_year
      expect(votes).to be_within(50).of(500)
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

  describe "#snakes?" do
    it "returns true when snakes is true" do
      game = described_class.new(snakes: true)
      expect(game.snakes?).to be true
    end

    it "returns false when snakes is not set" do
      game = described_class.new(name: "Test")
      expect(game.snakes?).to be false
    end
  end

  describe "#snakes_category" do
    it "returns integer of snakes_location" do
      game = described_class.new(snakes_location: "5A")
      expect(game.snakes_category).to eq(5)
    end

    it "returns 0 for non-numeric location" do
      game = described_class.new(snakes_location: "New Arrivals")
      expect(game.snakes_category).to eq(0)
    end
  end

  describe "#bgb?" do
    it "returns true when bgb is true and not preorder" do
      game = described_class.new(bgb: true, preorder: false)
      expect(game.bgb?).to be true
    end

    it "returns false when bgb is true but preorder" do
      game = described_class.new(bgb: true, preorder: true)
      expect(game.bgb?).to be false
    end
  end

  describe "#preorder?" do
    it "returns true when preorder is true" do
      game = described_class.new(preorder: true)
      expect(game.preorder?).to be true
    end

    it "returns false when preorder is not set" do
      game = described_class.new(name: "Test")
      expect(game.preorder?).to be false
    end
  end

  describe "#competitive?" do
    it "returns true when group is competitive" do
      game = described_class.new(min_player_count: 2, max_player_count: 4)
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
