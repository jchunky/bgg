# frozen_string_literal: true

require "robotstxt"

module Utils
  class RobotsChecker
    def initialize(user_agent: "*")
      @user_agent = user_agent
      @parsers = {}
    end

    def allowed?(url)
      uri = URI.parse(url)
      origin = "#{uri.scheme}://#{uri.host}"
      parser = parser_for(origin)
      parser.nil? || parser.allowed?(url)
    end

    private

    def parser_for(origin)
      return @parsers[origin] if @parsers.key?(origin)

      parser = Robotstxt::Parser.new(@user_agent)
      @parsers[origin] = parser.get(origin) ? parser : nil
    end
  end
end
