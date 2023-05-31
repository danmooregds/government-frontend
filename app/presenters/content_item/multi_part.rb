module ContentItem
  module MultiPart
    include Linkable
    include Updatable

    def breadcrumbs
      [{ title: I18n.t("manuals.breadcrumb_contents") }]
    end

    def parts
      content_item.dig("details", "parts") || []
    end
    def part_by_slug
      parts.find do |part|
        part.slug == params[:path].split('/').last
      end
    end
    def requesting_a_part?
      parts.any? && requested_path && requested_path != base_path
    end

    def has_valid_part?
      Rails.logger.warn('MultiPart has valid part?')
      Rails.logger.warn('parts: ' + parts.inspect)
      Rails.logger.warn('parts.first: ' + parts.first.inspect)
      Rails.logger.warn('current_part: ' + current_part.inspect)
      parts.any?
    end

    def current_part
      if part_slug
        parts.find { |part| part["slug"] == part_slug }
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
