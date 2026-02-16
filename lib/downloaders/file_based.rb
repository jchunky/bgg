module Downloaders
  class FileBased < Base
    def games
      @games ||= raw_records.filter_map { |data| parser.parse(data) }
    end

    private

    def raw_records = File.read(file_path).split(delimiter)

    def file_path
      raise NotImplementedError, "#{self.class} must implement #file_path"
    end

    def delimiter
      raise NotImplementedError, "#{self.class} must implement #delimiter"
    end

    def parser
      raise NotImplementedError, "#{self.class} must implement #parser"
    end
  end
end
