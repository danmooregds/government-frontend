module ContentItem
  module MultiPart
    include Linkable
    include Updatable

    def page_title
      title = content_item["title"] || ""
      title += " - " if title.present?
      I18n.t("multi_part.title", title:)
    end
    alias_method :multi_part_title, :page_title

    def breadcrumbs
      [{ title: I18n.t("manuals.breadcrumb_contents") }]
    end

    def parts
      content_item.dig("details", "parts") || []
    end

    def requesting_a_part?
      parts.any? && requested_path && requested_path != base_path
    end

    def has_valid_part?
      current_part && current_part != parts.first
    end

    def current_part
      if part_slug
        parts.find { |part| part["slug"] == part_slug }
      else
        parts.first
      end
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
    def multi_part_metadata
      {
        from:,
        first_published: published,
        other: other_metadata,
        inverse: true,
      }
    end
  end
end
