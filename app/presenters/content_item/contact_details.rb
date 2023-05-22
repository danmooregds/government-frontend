module ContentItem
  module ContactDetails
    def email_address_groups
      content_item["details"]["email_addresses"] || []
    end

    def post_address_groups
      content_item["details"]["post_addresses"] || []
    end

    def phone_number_groups
      content_item["details"]["phone_numbers"] || []
    end

    def online_form_links
      contact_form_links = content_item["details"]["contact_form_links"] || []
      contact_form_links.map do |link|
        {
          url: link["link"],
          title: link["title"],
          description: link["description"].try(:html_safe),
        }.with_indifferent_access
      end
    end

    def address_hash(address)
      {
        fn: address["title"],
        "street-address": address["street_address"],
        locality: address["locality"],
        region: address["region"],
        "postal-code": address["postal_code"],
        "country-name": address["world_location"],
      }.compact.with_indifferent_access
    end
  end
end
