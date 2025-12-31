module ImageHelper
  def resize_image(image, width:, height:)
    image.variant(resize_to_limit: [ width, height ]) if image.attached?
  end

  def product_card_image(product)
    resize_image(product.image, width: 400, height: 300) || "placeholder-card.png"
  end

  def product_primary_large(product)
    resize_image(product.image, width: 800, height: 600) || "placeholder-large.png"
  end

  def product_thumb(image_blob)
    resize_image(image_blob, width: 160, height: 160)
  end

  def admin_thumb(image_blob)
    resize_image(image_blob, width: 120, height: 120)
  end
end
