module ReviewsHelper
  def star_rating(review)
    full_stars = review.rating.to_i
    empty_stars = 5 - full_stars
    "★" * full_stars + "☆" * empty_stars
  end

  def reviewer_name(review)
    review.user&.name || "Anonymous"
  end

  def review_date(review)
    review.created_at.strftime("%B %d, %Y")
  end

  def review_summary(review)
    "#{reviewer_name(review)} — #{star_rating(review)} — #{review_date(review)}"
  end

  def average_rating(product)
    return "No reviews yet" if product.reviews.empty?
    avg = product.reviews.average(:rating).to_f.round(1)
    "Average rating: #{avg}/5"
  end
end
