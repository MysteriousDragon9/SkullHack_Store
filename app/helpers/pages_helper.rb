module PagesHelper
  def page_title(page)
    base = "MyStore"
    page.present? ? "#{page.title} | #{base}" : base
  end

  def render_page_content(page)
    sanitize(page.content, tags: %w[p br h1 h2 h3 ul ol li strong em a], attributes: %w[href])
  end

  def page_nav_link(page)
    link_to page.title, page_path(page.slug), class: "nav-link"
  end

  def page_last_updated(page)
    "Last updated: #{page.updated_at.strftime('%B %d, %Y')}"
  end
end
