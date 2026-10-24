require "rails_helper"
require "axlsx"

# Requirement: Uploaded file parsing
RSpec.describe Print::FileParser do
  let(:rows_data) { [ [ "name", "age" ], [ "Amy", "30" ] ] }
  let(:csv_path) { Rails.root.join("tmp", "file_parser_spec.csv") }
  let(:xlsx_path) { Rails.root.join("tmp", "file_parser_spec.xlsx") }

  def upload(path, extension)
    content_type = extension == "csv" ? "text/csv" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    Rack::Test::UploadedFile.new(path, content_type, original_filename: "data.#{extension}")
  end

  before do
    File.write(csv_path, rows_data.map { |row| row.join(",") }.join("\n"))

    package = Axlsx::Package.new
    package.workbook.add_worksheet do |sheet|
      rows_data.each { |row| sheet.add_row(row, types: row.map { :string }) }
    end
    package.serialize(xlsx_path.to_s)
  end

  after do
    [ csv_path, xlsx_path ].each { |path| File.delete(path) if File.exist?(path) }
  end

  describe "#rows" do
    it "parses a .csv file into a list of rows of cell values" do
      expect(described_class.new(upload(csv_path, "csv")).rows).to eq(rows_data)
    end

    it "parses a .xlsx file into the same row structure as csv" do
      expect(described_class.new(upload(xlsx_path, "xlsx")).rows).to eq(rows_data)
    end

    # Example: equivalent csv and xlsx output
    it "produces identical rows for equivalent csv and xlsx content" do
      csv_rows = described_class.new(upload(csv_path, "csv")).rows
      xlsx_rows = described_class.new(upload(xlsx_path, "xlsx")).rows

      expect(xlsx_rows).to eq(csv_rows)
      expect(csv_rows).to eq([ [ "name", "age" ], [ "Amy", "30" ] ])
    end

    it "raises a clear error for an unsupported file extension" do
      txt_upload = Rack::Test::UploadedFile.new(csv_path, "text/plain", original_filename: "data.txt")

      expect { described_class.new(txt_upload).rows }
        .to raise_error(Print::FileParser::UnsupportedFileError, "Unsupported file type: .txt")
    end
  end
end
