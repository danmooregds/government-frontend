module Supergroups
  class Services
    attr_reader :content

    def initialize(taxon_ids)
      @taxon_ids = taxon_ids
      @content = MostPopularContent.fetch(content_ids: @taxon_ids, filter_content_purpose_supergroup: "services")
    end

    def all_services
      {
        documents: tagged_content,
        promoted_content: promoted_content,
      }
    end

    def tagged_content
      items = @content.drop(promoted_content_count)
      format_document_data(items)
    end

    def promoted_content
      items = @content.shift(promoted_content_count)
      format_document_data(items, "HighlightBoxClicked")
    end

  private

    def promoted_content_count
      3
    end

    def format_document_data(documents, data_category = "DocumentListClicked")
      documents.each.with_index(1)&.map do |document, index|
        data = {
          link: {
            text: document["title"],
            path: document["link"],
            data_attributes: {
              track_category: "Services" + data_category,
              track_action: index,
              track_label: document["link"],
              track_options: {
                dimension29: document["title"],
              }
            }
          }
        }

        data
      end
    end
  end
end
