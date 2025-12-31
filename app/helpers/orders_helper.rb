module OrdersHelper
  def format_order_total(order)
    number_to_currency(order.total, unit: "$", precision: 2)
  end

  def order_status_badge(order)
    case order.status.to_s
    when "pending" then content_tag(:span, "Pending", class: "badge bg-warning")
    when "paid"    then content_tag(:span, "Paid", class: "badge bg-success")
    when "shipped" then content_tag(:span, "Shipped", class: "badge bg-info")
    else content_tag(:span, order.status.titleize, class: "badge bg-secondary")
    end
  end

  def tax_breakdown(order)
    [
      "GST: #{number_to_currency(order.gst_amount)}",
      "PST: #{number_to_currency(order.pst_amount)}",
      "HST: #{number_to_currency(order.hst_amount)}"
    ].join(" | ").html_safe
  end

  def order_summary(order)
    "Order ##{order.id} — #{order_status_badge(order)} — #{format_order_total(order)}"
  end

  def badge_class_for(status)
    case status.to_s
    when "pending"
      "bg-warning text-dark"
    when "paid"
      "bg-success"
    when "cancelled"
      "bg-danger"
    when "shipped"
      "bg-info"
    else
      "bg-secondary"
    end
  end
end
