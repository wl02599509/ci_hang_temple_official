module Print
  # Immutable value object describing a single print item shown on the print
  # overview page (/admin/print). Loaded from config/admin/print.yml by
  # Print::Registry.
  Definition = Data.define(:slug, :title, :description, :path)
end
