require "zeitwerk"

module Loader
  def self.setup
    loader = Zeitwerk::Loader.new
    loader.push_dir(File.expand_path(__dir__))
    loader.setup
    loader
  end
end
