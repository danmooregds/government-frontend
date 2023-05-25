module ContentItem
  module MultiPart
    include Linkable
    include Updatable

    def multi_part_metadata
      {
        from:,
        first_published: published,
        other: other_metadata,
        inverse: true,
      }
    end
    def page_title
      title = content_item["title"] || ""
      title += " - " if title.present?
    end
    alias_method :manual_page_title, :page_title

    def breadcrumbs
      [{ title: I18n.t("manuals.breadcrumb_contents") }]
    end

    def parts
      content_item.dig("details", "parts") || []
    end

    def body
      details["body"]
    end


  private

    def other_metadata
      updated_metadata(public_updated_at)
    end

    def updated_metadata(updated_at)
      updates_link = view_context.link_to(I18n.t("manuals.see_all_updates"), "#{base_path}/updates")
      { I18n.t("manuals.updated") => "#{display_date(updated_at)}, #{updates_link}" }
    end

    def details
      content_item["details"]
    end
  end
end
