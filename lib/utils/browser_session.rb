# frozen_string_literal: true

require "ferrum"

module Utils
  class BrowserSession
    def initialize
      @browser = Ferrum::Browser.new(headless: true)
    end

    def html(url)
      @browser.goto(url)
      @browser.body
    end

    def page = @browser.page

    def quit = @browser.quit
  end
end
