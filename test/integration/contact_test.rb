require "test_helper"

class ContactTest < ActionDispatch::IntegrationTest
  test "random but valid items do not error" do
    setup_and_visit_random_content_item
  end

  test "online forms are rendered" do
    setup_and_visit_content_item("contact")

    assert page.has_text?("If HMRC needs to contact you about anything confidential they’ll reply by phone or post.")
    assert page.has_text?("Contact HMRC to report suspicious activity in relation to smuggling, customs, excise and VAT fraud.")

    assert page.has_css?("h2#online-forms-title")
    first_contact_form_link = @content_item["details"]["contact_form_links"].first
    assert page.has_css?("a[href='#{first_contact_form_link['link']}']")
  end

  test "emails are rendered" do
    setup_and_visit_content_item("contact")

    assert page.has_css?("h2#email-title")
    assert page.has_css?(".email:first-of-type")
  end

  test "phones are rendered" do
    setup_and_visit_content_item("contact")

    first_phone = @content_item["details"]["phone_numbers"].first

    assert page.has_css?("h2#phone-title")
    assert page.has_css?("h3", text: first_phone["title"])
    assert page.has_css?("p", text: first_phone["number"])
    assert page.has_css?("p", text: "24 hours a day, 7 days a week")
  end

  test "phone number heading is not rendered when only one number" do
    setup_and_visit_content_item("contact_with_welsh")

    assert_equal 1, @content_item["details"]["phone_numbers"].size
    first_phone = @content_item["details"]["phone_numbers"].first
    assert_not page.has_css?("h3", text: first_phone["title"])
  end

  test "posts are rendered" do
    setup_and_visit_content_item("contact")

    assert page.has_css?("h2#post-title")
    assert page.has_css?(".street-address")
  end

  test "does not render with the single page notification button" do
    setup_and_visit_content_item("contact")
    assert_not page.has_css?(".gem-c-single-page-notification-button")
  end

  # Ideally this would be tested at the Controller level however the
  # ActionController::TestCase does not integrate with CSP, so tested at a level
  # which does.
  test "the content security policy is updated for webchat hosts" do
    # Need to use Rack as Selenium, the default driver, doesn't provide header access
    Capybara.current_driver = :rack_test

    webchat = Webchat.new({
      "base_path" => "/content",
      "open_url" => "https://webchat.host/open",
      "availability_url" => "https://webchat.host/avaiable",
      "csp_connect_src" => "https://webchat.host",
    })

    Webchat.stubs(:find).returns(webchat)

    setup_and_visit_content_item("contact")
    parsed_csp = page.response_headers["Content-Security-Policy"]
                     .split(";")
                     .map { |directive| directive.strip.split(" ") }
                     .each_with_object({}) { |directive, memo| memo[directive.first] = directive[1..] }

    assert_includes parsed_csp["connect-src"], "https://webchat.host"

    # reset back to default driver
    Capybara.use_default_driver
  end
end
