# frozen_string_literal: true

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
require "yaml"

require_relative "lib/loader"
Loader.setup

class Bgg
  def run
    Config::Downloaders::DOWNLOADERS.each do |downloader|
      p [downloader.prefix, "listid: #{downloader.listid}", downloader.games.size]
    end

    games = Services::GameRanker.new.call(Services::GameAggregator.new.call)
      .select(&Models::GameFilter)
      .sort_by { |g| -g.weight }

    File.write("index.html", Presenters::GamesPage.new(games).render)
  end
end

Bgg.new.run
