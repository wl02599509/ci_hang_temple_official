require "rails_helper"

# Requirement: Print registry
RSpec.describe Print::Registry do
  let(:config_path) { Rails.root.join("tmp", "print_registry_spec.yml") }

  def write_config(yaml)
    File.write(config_path, yaml)
  end

  after { File.delete(config_path) if File.exist?(config_path) }

  describe ".all" do
    context "when items are registered" do
      before do
        write_config(<<~YAML)
          print_items:
            - slug: member-roster
              title: 會員名冊
              description: 上傳會員名單,列印格式化名冊
              path: /admin/print/member-roster
        YAML
      end

      let(:expected_attributes) do
        {
          slug: "member-roster",
          title: "會員名冊",
          description: "上傳會員名單,列印格式化名冊",
          path: "/admin/print/member-roster"
        }
      end

      it "returns one Definition per configured item exposing slug/title/description/path" do
        expect(described_class.all(path: config_path)).to contain_exactly(
          an_instance_of(Print::Definition).and(have_attributes(expected_attributes))
        )
      end
    end

    it "returns an empty array when no items are registered" do
      write_config("print_items: []\n")

      expect(described_class.all(path: config_path)).to eq([])
    end
  end

  describe ".find" do
    before do
      write_config(<<~YAML)
        print_items:
          - slug: roster
            title: 名冊
            description: 名冊說明
            path: /admin/print/roster
      YAML
    end

    it "returns the matching definition when the slug is registered" do
      definition = described_class.find("roster", path: config_path)

      expect(definition).to be_a(Print::Definition)
      expect(definition.slug).to eq("roster")
    end

    it "returns nil when the slug is not registered" do
      expect(described_class.find("unknown", path: config_path)).to be_nil
    end
  end
end
