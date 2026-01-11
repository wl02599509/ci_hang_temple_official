module ApplicationHelper
  def form_error_class(resource, attribute)
    resource.errors[attribute].any? ? "!border-red-500" : ""
  end

  def display_field_errors(resource, attribute)
    return unless resource.errors[attribute].any?

    content_tag(:div, class: "text-red-500 text-sm mt-1") do
      resource.errors[attribute].join("、")
    end
  end
end
