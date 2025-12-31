module CategoriesHelper
  def category_label(category)
    "#{category.name} (#{category.products.count})"
  end

  def active_category_class(category, current_category)
    "active" if category == current_category
  end

  def category_icon(category)
    case category.slug
    when "electronics" then "📱"
    when "books"       then "📚"
    when "clothing"    then "👕"
    else "📦"
    end
  end

  def category_options
    Category.order(:name).pluck(:name, :id)
  end
end
