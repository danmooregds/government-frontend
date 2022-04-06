module ContentItem
  module ManualSection
    def title
      manual["title"]
    end

    def page_title
      "#{breadcrumb} - #{manual_page_title}"
    end

    def document_heading
      document_heading = []

      document_heading << details["section_id"] if details["section_id"]
      document_heading << content_item["title"] if content_item["title"]
    end

    def breadcrumb
      details["section_id"] || title
    end

    def manual_content_item
      # TODO: Add the same tagging to a normal section as a manual for contextual breadcrumbs
      # TODO: Add the manual title to the HMRC section content item and then we can remove this request (manual_content_item)
      @manual_content_item ||= Services.content_store.content_item(base_path)
    end
  end
end
