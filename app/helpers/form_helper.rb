module FormHelper
  def form_errors_for(resource, message: nil)
    return if resource.errors.empty?

    header = message || "#{resource.errors.count} error(s) prevented this form from being saved:"

    content_tag(:div, class: "alert alert-danger", role: "alert") do
      content_tag(:p, header) +
      content_tag(:ul) do
        safe_join(resource.errors.full_messages.map { |m| content_tag(:li, m) })
      end
    end
  end
end
