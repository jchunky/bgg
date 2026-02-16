require_relative "../../spec_helper"

RSpec.describe Parsers::Concerns::PlayerCountParser do
  let(:parser_class) do
    Class.new do
      include Parsers::Concerns::PlayerCountParser
      public :parse_player_count
    end
  end

  let(:parser) { parser_class.new }

  describe "#parse_player_count" do
    context "with range format" do
      it "parses '1-4' as [1, 4]" do
        expect(parser.parse_player_count("1-4")).to eq([1, 4])
      end

      it "parses '2-6' as [2, 6]" do
        expect(parser.parse_player_count("2-6")).to eq([2, 6])
      end
    end

    context "with single number format" do
      it "parses '2' as [2, 2]" do
        expect(parser.parse_player_count("2")).to eq([2, 2])
      end

      it "parses '1' as [1, 1]" do
        expect(parser.parse_player_count("1")).to eq([1, 1])
      end
    end

    context "with blank input" do
      it "returns [nil, nil] for nil" do
        expect(parser.parse_player_count(nil)).to eq([nil, nil])
      end

      it "returns [nil, nil] for empty string" do
        expect(parser.parse_player_count("")).to eq([nil, nil])
      end
    end
  end
end
