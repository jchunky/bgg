# frozen_string_literal: true

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "ostruct"
require "uri"
require "yaml"

require_relative "lib/loader"
Loader.setup

class Bgg
  include Services::ViewHelpers

  def run
    Config::Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    @games = Services::GameRanker.new.call(Services::GameAggregator.new.call)
      .select(&:displayable?)
      .sort_by { |g| -g.weight }

    write_output
  end

  private

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end
end

Bgg.new.run
