module WorldwideOrganisation
  class LinkedContactPresenter
    include ActionView::Helpers::TagHelper

    attr_reader :details

    def initialize(content_item)
      @details = content_item.with_indifferent_access["details"]
    end

    def post_address
      content_item_address = details["post_addresses"]&.first

      return if content_item_address.nil?

      address_hash  = {
        fn: content_item_address["title"],
        "street-address": content_item_address["street_address"],
        locality: content_item_address["locality"],
        region:  content_item_address["region"],
        "postal-code": content_item_address["postal_code"],
        "country-name": content_item_address["world_location"]
      }

      tag.address address_hash.values.compact.join("<br/>").html_safe, class: %w[govuk-body font-normal]
    end

    def email
      email_address = details["email_addresses"]&.first

      email_address&.dig("email")
    end

    def contact_form_link
      contact_form_link = details["contact_form_links"]&.first

      contact_form_link&.dig("link")
    end

    def phone_numbers
      details["phone_numbers"]
    end

    def comments
      tag.p(details["description"].gsub("\r\n", "<br/>").html_safe, class: %w[govuk-body]) if details["description"].present?
    end
  end
end
