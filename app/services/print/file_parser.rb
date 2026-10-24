require "csv"

module Print
  # Parses an uploaded .xlsx or .csv file into a uniform list of rows, where
  # each row is a list of (string) cell values. The parsing strategy is chosen
  # from the file extension. Unsupported extensions raise UnsupportedFileError.
  class FileParser
    class UnsupportedFileError < StandardError; end

    def initialize(file)
      @file = file
    end

    # @return [Array<Array(String, nil)>]
    def rows
      case extension
      when ".csv"  then parse_csv
      when ".xlsx" then parse_xlsx
      else
        raise UnsupportedFileError, "Unsupported file type: #{extension.presence || 'unknown'}"
      end
    end

    private

    def extension
      File.extname(filename).downcase
    end

    def filename
      @file.respond_to?(:original_filename) ? @file.original_filename : @file.to_s
    end

    def file_path
      @file.respond_to?(:path) ? @file.path : @file.to_s
    end

    def parse_csv
      CSV.read(file_path).map { |row| normalize(row) }
    end

    def parse_xlsx
      sheet = Roo::Excelx.new(file_path).sheet(0)
      sheet.to_a.map { |row| normalize(row) }
    end

    # Cells are normalized to strings so xlsx and csv produce equivalent output;
    # blank cells are preserved as nil.
    def normalize(row)
      row.map { |cell| cell.nil? ? nil : cell.to_s }
    end
  end
end
