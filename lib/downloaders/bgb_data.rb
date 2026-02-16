module Downloaders
  class BgbData < FileBased
    def prefix = :bgb_data
    def listid = "bgb_data"

    private

    def file_path = "./data/bgb.txt"
    def delimiter = "\n\n"
    def parser = Parsers::BgbGame
  end
end
