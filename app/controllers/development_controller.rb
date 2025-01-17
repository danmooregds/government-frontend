class DevelopmentController < ApplicationController
  layout false

  def index
    @schema_names = %w[answer
                       case_study
                       consultation
                       contact
                       corporate_information_page
                       detailed_guide
                       document_collection
                       fatality_notice
                       guide
                       help_page
                       html_publication
                       news_article
                       placeholder_corporate_information_page
                       publication
                       service_sign_in
                       specialist_document
                       speech
                       statistical_data_set
                       statistics_announcement
                       take_part
                       topical_event_about_page
                       travel_advice
                       working_group]

    @paths = YAML.load_file(Rails.root.join("config/govuk_examples.yml"))
  end

private

  helper_method :remove_secrets

  def remove_secrets(original_url)
    parsed_url = URI.parse(original_url)
    original_url = original_url.gsub(parsed_url.user, "***") if parsed_url.user
    original_url = original_url.gsub(parsed_url.password, "***") if parsed_url.password
    original_url
  end
end
