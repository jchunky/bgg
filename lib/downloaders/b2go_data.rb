module Downloaders
  class B2goData < FileBased
    def prefix = :b2go_data
    def listid = "b2go_data"

    private

    def file_path = "./data/b2go.txt"
    def delimiter = "\n"
    def parser = Parsers::B2goGame

    def raw_records = super.each_slice(4).to_a
  end
end
