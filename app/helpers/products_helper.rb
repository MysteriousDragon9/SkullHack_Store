module ProductsHelper
  def product_image_tag(product, options = {})
    base_options = { class: "card-img-top", loading: "lazy" }.merge(options)

    if product.image.attached?
      image_tag product_card_image(product), base_options.merge(alt: product.name)
    else
      image_tag "placeholder.png", base_options.merge(alt: "Image not available for #{product.name}")
    end
  end
end
