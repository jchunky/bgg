# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Models::NormalizedName do
  describe ".from" do
    it "lowercases and strips special characters" do
      expect(described_class.from("Test: Game!").to_s).to eq("test game")
    end

    it "squishes whitespace" do
      expect(described_class.from("Test   Game").to_s).to eq("test game")
    end

    it "strips articles 'the' and 'a'" do
      expect(described_class.from("The Lord of the Rings").to_s)
        .to eq("lord of rings")
    end

    it "normalizes & to 'and'" do
      expect(described_class.from("Air, Land & Sea"))
        .to eq(described_class.from("Air, Land and Sea"))
    end

    it "normalizes accented characters" do
      expect(described_class.from("Khôra: Rise of an Empire"))
        .to eq(described_class.from("Khora: Rise of an Empire"))
    end

    it "strips possessive 's" do
      expect(described_class.from("Agatha Christie's Death on the Cards"))
        .to eq(described_class.from("Agatha Christie: Death on the Cards"))
    end

    it "normalizes ordinals to numbers" do
      expect(described_class.from("7 Wonders: 2nd Edition"))
        .to eq(described_class.from("7 Wonders (Second Edition)"))
    end

    it "strips the word 'edition'" do
      expect(described_class.from("Mansions of Madness: Second Edition").to_s)
        .to eq("mansions of madness 2")
    end
  end

  describe "value equality" do
    it "considers same normalized values equal" do
      a = described_class.from("A Game of Cat & Mouth")
      b = described_class.from("A Game of Cat and Mouth")
      expect(a).to eq(b)
    end

    it "works as a hash key" do
      a = described_class.from("The Council of Shadows")
      b = described_class.from("Council of Shadows")
      hash = { a => true }
      expect(hash[b]).to be true
    end
  end

  describe "#to_s" do
    it "returns the normalized string" do
      expect(described_class.from("Test Game").to_s).to eq("test game")
    end
  end

  describe "#to_str" do
    it "allows implicit string coercion" do
      name = described_class.from("Test Game")
      expect("key: #{name}").to eq("key: test game")
    end
  end
end
