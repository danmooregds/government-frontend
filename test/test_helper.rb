ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"
ENV["GOVUK_ASSET_ROOT"] = "http://static.test.gov.uk"

# Must go at top of file
require "simplecov"
SimpleCov.start

require "i18n/coverage"
require "i18n/coverage/printers/file_printer"
I18n::Coverage.config.printer = I18n::Coverage::Printers::FilePrinter
I18n::Coverage.start

require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "capybara/rails"
require "mocha/minitest"
require "capybara/minitest"
require "faker"
require "minitest/reporters"

Dir[Rails.root.join("test/support/*.rb")].sort.each { |f| require f }

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

GovukTest.configure

Capybara.default_driver = :headless_chrome

GovukAbTesting.configure do |config|
  config.acceptance_test_framework = :active_support
end

WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  include GovukContentSchemaExamples
end

# NOTE: This is so that slimmer is skipped, preventing network requests for
# content from static (i.e. core_layout.html.erb).
class ActionController::Base
  before_action :set_skip_slimmer_header

  def set_skip_slimmer_header
    response.headers[Slimmer::Headers::SKIP_HEADER] = "true" unless ENV["USE_SLIMMER"]
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include ActionView::Helpers::DateHelper
  include I18n

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def assert_has_component_metadata_pair(label, value)
    assert page.has_content?(label)
    assert page.has_content?(value)
  end

  def assert_has_component_title(title)
    assert page.has_css?("h1", text: title)
  end

  def assert_has_component_organisation_logo
    assert page.has_css?(".gem-c-organisation-logo")
  end

  def assert_has_contents_list(contents)
    assert page.has_css?(".gem-c-contents-list"), "Failed to find an element with a class of contents-list"
    within ".gem-c-contents-list" do
      contents.each do |heading|
        selector = "a[href=\"##{heading[:id]}\"]"
        text = heading.fetch(:text)
        assert page.has_css?(selector), "Failed to find an element matching: #{selector}"
        assert page.has_css?(selector, text:), "Failed to find an element matching #{selector} with text: #{text}"
      end
    end
  end

  def assert_has_published_dates(first_published = nil, last_updated = nil, history_link: false)
    text = []
    text << first_published if first_published
    text << last_updated if last_updated
    last_published_dates_element = all(".app-c-published-dates").last

    within last_published_dates_element do
      assert page.has_text?(text.join("\n")), "Published dates #{text.join("\n")} not found"
      if history_link
        assert page.has_link?("see all updates", href: "#history"), "Updates link not found"
      end
    end
  end

  def assert_has_publisher_metadata_other(any_args)
    assert_has_metadata(any_args)
  end

  def assert_has_metadata(any_args, extra_metadata_classes: nil)
    within ".gem-c-metadata#{extra_metadata_classes}" do
      any_args.each do |_key, value|
        value = { value => nil } if value.is_a?(String)
        value.each do |text, href|
          if href
            assert page.has_link?(text, href:), "Metadata text '#{text} with link of #{href}' not found"
          else
            assert page.has_text?(text), "Metadata value '#{text}' not found"
          end
        end
      end
    end
  end

  def assert_has_metadata_local(metadata, term_selector, definition_selector)
    metadata.each do |key, value|
      assert page.has_css?(term_selector, text: key),
             "Metadata term '#{key}' not found"
      value = { value => nil } if value.is_a?(String)
      value.each do |text, href|
        within(definition_selector, text:) do
          if href
            assert page.has_link?(text, href:), "Metadata link '#{text}' not found"
          else
            assert page.has_text?(text), "Metadata value '#{text}' not found"
          end
        end
      end
    end
  end

  def assert_has_publisher_metadata(options)
    within(".app-c-publisher-metadata") do
      assert_has_published_dates(options[:first_published], options[:last_updated], history_link: options[:history_link])
      assert_has_publisher_metadata_other(options[:metadata])
    end
  end

  def assert_has_important_metadata(metadata)
    within(".app-c-important-metadata") do
      assert_has_metadata_local(
        metadata, ".app-c-important-metadata__term", ".app-c-important-metadata__definition"
      )
    end
  end

  def assert_has_devolved_nations_component(text, nations = nil)
    within(".gem-c-devolved-nations") do
      assert page.has_text?(text)
      nations&.each do |nation|
        assert page.has_link?(nation[:text], href: nation[:alternative_url])
      end
    end
  end

  def assert_footer_has_published_dates(first_published = nil, last_updated = nil, history_link: false)
    assert_has_published_dates(first_published, last_updated, history_link:)
  end

  def setup_and_visit_content_item(name, overrides = {}, parameter_string = "")
    @content_item = get_content_example(name).tap do |item|
      content_item = item.deep_merge(overrides)
      stub_content_store_has_item(content_item["base_path"], content_item.to_json)
      visit_with_cachebust("#{content_item['base_path']}#{parameter_string}")
    end
  end

  def setup_and_visit_content_item_with_params(name, parameter_string = "")
    @content_item = get_content_example(name)
    stub_content_store_has_item(@content_item["base_path"], @content_item.to_json)
    visit_with_cachebust("#{@content_item['base_path']}#{parameter_string}")
  end

  def setup_and_visit_html_publication(name, parameter_string = "")
    @content_item = get_content_example(name).tap do |item|
      parent = item["links"]["parent"][0]
      stub_content_store_has_item(item["base_path"], item.to_json)
      stub_content_store_has_item(parent["base_path"], parent.to_json)
      visit_with_cachebust("#{item['base_path']}#{parameter_string}")
    end
  end

  def setup_and_visit_content_item_with_taxons(name, taxons)
    @content_item = get_content_example(name).tap do |item|
      item["links"]["taxons"] = taxons
      stub_content_store_has_item(item["base_path"], item.to_json)
      visit_with_cachebust(item["base_path"])
    end
  end

  def setup_and_visit_notification_exempt_page(name)
    @content_item = get_content_example(name).tap do |item|
      item["content_id"] = ContentItem::SinglePageNotificationButton::EXEMPTION_LIST[0]
      stub_content_store_has_item(item["base_path"], item.to_json)
      visit_with_cachebust((item["base_path"]).to_s)
    end
  end

  def setup_and_visit_a_page_with_specific_base_path(name, base_path, content_id = nil)
    @content_item = get_content_example(name).tap do |item|
      item["content_id"] = content_id if content_id.present?
      item["base_path"] = base_path
      stub_content_store_has_item(item["base_path"], item.to_json)
      visit_with_cachebust(item["base_path"])
    end
  end

  def setup_and_visit_random_content_item(document_type: nil)
    content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: schema_type) do |payload|
      payload.merge!("document_type" => document_type) unless document_type.nil?
      payload
    end

    content_id = content_item["content_id"]
    path = content_item["base_path"]

    if schema_type == "html_publication"
      parent = content_item.dig("links", "parent")&.first
      if parent
        parent_path = parent["base_path"]
        stub_request(:get, %r{#{parent_path}})
          .to_return(status: 200, body: content_item.to_json, headers: {})
      end
    end

    stub_request(:get, %r{#{path}})
      .to_return(status: 200, body: content_item.to_json, headers: {})

    visit path

    assert_selector %(meta[name="govuk:content-id"][content="#{content_id}"]), visible: false
  end

  def get_content_example(name)
    get_content_example_by_schema_and_name(schema_type, name)
  end

  def get_content_example_by_schema_and_name(schema_type, name)
    GovukSchemas::Example.find(schema_type, example_name: name)
  end

  # Override this method if your test file doesn't match the convention
  def schema_type
    self.class.to_s.gsub("Test", "").underscore
  end

  def visit_with_cachebust(visit_uri)
    uri = Addressable::URI.parse(visit_uri)
    uri.query_values = uri.query_values.yield_self { |values| (values || {}).merge(cachebust: rand) }

    visit(uri)
  end

  def assert_has_structured_data(page, schema_name)
    assert find_structured_data(page, schema_name).present?
  end

  def find_structured_data(page, schema_name)
    schema_sections = page.find_all("script[type='application/ld+json']", visible: false)
    schemas = schema_sections.map { |section| JSON.parse(section.text(:all)) }

    schemas.detect { |schema| schema["@type"] == schema_name }
  end
end
