class MultiPartPresenter < ContentItemPresenter
  include ContentItem::Metadata
  include ContentItem::MultiPart
  include ContentItem::Parts

  def page_title
  "#{current_part_title} - #{super}"
  end

  def metadata
    reviewed_at = content_item["details"]["reviewed_at"]
    updated_at = content_item["details"]["updated_at"]

    other = {
      I18n.t("travel_advice.still_current_at") => I18n.l(Time.zone.now, format: "%-d %B %Y"),
      I18n.t("travel_advice.updated") => display_date(reviewed_at || updated_at),
    }

    other["Latest update"] = view_context.simple_format(latest_update, { class: "metadata__update" }, wrapper_tag: "span") if latest_update.present?

    {
      other:,
    }
  end

  def title_and_context
    {
      context: I18n.t("travel_advice.context"),
      title: country_name,
    }
  end

end
