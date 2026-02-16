module Downloaders
  class BgoData < FileBased
    def prefix = :bgo_data
    def listid = "bgo_data"

    private

    def file_path = "./data/bgo.txt"
    def delimiter = "\n\n"
    def parser = Parsers::BgoGame
  end
end
