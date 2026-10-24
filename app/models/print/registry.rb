module Print
  # Loads print item definitions from config/admin/print.yml.
  #
  # Each future print item registers a definition here so it appears as a card
  # on the print overview page. The abstraction layer ships with an empty
  # registry; individual items are added by their own change proposals.
  class Registry
    CONFIG_PATH = Rails.root.join("config", "admin", "print.yml").freeze

    ATTRIBUTES = %i[slug title description path].freeze

    class << self
      # @return [Array<Print::Definition>]
      def all(path: CONFIG_PATH)
        items = YAML.load_file(path)&.fetch("print_items", nil) || []

        items.map do |attrs|
          Definition.new(**attrs.symbolize_keys.slice(*ATTRIBUTES))
        end
      end

      # @return [Print::Definition, nil]
      def find(slug, path: CONFIG_PATH)
        all(path: path).find { |definition| definition.slug == slug.to_s }
      end
    end
  end
end
