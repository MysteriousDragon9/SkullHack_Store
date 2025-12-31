module UiHelper
  def page_title(title = nil, &block)
    content_for(:title) { [ title, "Skullhack Store" ].compact.join(" · ") }
    content_tag(:h1, block_given? ? capture(&block) : (title || "Skullhack Store"))
  end

  def breadcrumbs(*items)
    content_tag(:nav, aria: { label: "breadcrumb" }, role: "navigation") do
      content_tag(:ol, class: "breadcrumb") do
        safe_join(items.map.with_index do |(label, path), i|
          if i == items.size - 1 || path.nil?
            content_tag(:li, label, class: "breadcrumb-item active", aria: { current: "page" })
          else
            content_tag(:li, class: "breadcrumb-item") { link_to(label, path) }
          end
        end)
      end
    end
  end

  def breadcrumb_item(label, path = nil)
    [ label, path ]
  end
end
