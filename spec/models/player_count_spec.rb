# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Models::PlayerCount do
  describe "#to_s" do
    it "joins min and max with dash when they differ" do
      expect(described_class.new(min: 2, max: 4).to_s).to eq("2-4")
    end

    it "returns single number when min equals max" do
      expect(described_class.new(min: 1, max: 1).to_s).to eq("1")
    end
  end

  describe "#range" do
    it "returns a range from min to max" do
      expect(described_class.new(min: 1, max: 4).range).to eq(1..4)
    end
  end

  describe "#one_player?" do
    it "returns true when max is 1" do
      expect(described_class.new(min: 1, max: 1).one_player?).to be true
    end

    it "returns false when max exceeds 1" do
      expect(described_class.new(min: 1, max: 4).one_player?).to be false
    end
  end

  describe "#two_player?" do
    it "returns true when max is 2" do
      expect(described_class.new(min: 1, max: 2).two_player?).to be true
    end

    it "returns false when max is not 2" do
      expect(described_class.new(min: 1, max: 4).two_player?).to be false
    end
  end

  describe "#soloable?" do
    it "returns true for solo-only games" do
      pc = described_class.new(min: 1, max: 1)
      expect(pc.soloable?(coop: false)).to be true
    end

    it "returns true for coop games starting at 1 player" do
      pc = described_class.new(min: 1, max: 4)
      expect(pc.soloable?(coop: true)).to be true
    end

    it "returns false for non-coop multiplayer games" do
      pc = described_class.new(min: 2, max: 4)
      expect(pc.soloable?(coop: false)).to be false
    end
  end

  describe "#unknown?" do
    it "returns true when min is zero" do
      expect(described_class.new(min: 0, max: 0).unknown?).to be true
    end

    it "returns false when min is positive" do
      expect(described_class.new(min: 1, max: 4).unknown?).to be false
    end
  end

  describe "value equality" do
    it "considers two instances with same values equal" do
      a = described_class.new(min: 1, max: 4)
      b = described_class.new(min: 1, max: 4)
      expect(a).to eq(b)
    end
  end
end
