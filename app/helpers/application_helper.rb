module ApplicationHelper
  def format_price(amount)
    number_to_currency(amount, unit: "$", precision: 2)
  end

  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-success"
    when :alert  then "alert alert-danger"
    else "alert alert-info"
    end
  end

  def page_title(title = nil)
    base = "MyStore"
    title.present? ? "#{title} | #{base}" : base
  end

  def status_icon(status)
    case status
    when "paid"     then "Checked"
    when "pending"  then "Waiting "
    when "shipped"  then "Boxing "
    else "❔"
    end
  end
end
