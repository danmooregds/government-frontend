require "test_helper"

class DetailedGuideTest < ActionDispatch::IntegrationTest
  test "random but valid items do not error" do
    setup_and_visit_random_content_item
  end

  test "detailed guide" do
    setup_and_visit_content_item("detailed_guide")

    assert_has_component_title(@content_item["title"])
    assert page.has_text?(@content_item["description"])
    assert_has_metadata({ published: "12 June 2014",
                          last_updated: "18 February 2016",
                          from: { "HM Revenue & Customs": "/government/organisations/hm-revenue-customs" } })
  end

  test "renders back to contents elements" do
    setup_and_visit_content_item("detailed_guide")

    assert page.has_css?(".app-c-back-to-top[href='#contents']")
  end

  test "withdrawn detailed guide" do
    setup_and_visit_content_item("withdrawn_detailed_guide")

    assert page.has_css?("title", text: "[Withdrawn]", visible: false)

    assert page.has_text?("This guidance was withdrawn"), "is withdrawn"
    assert page.has_text?("This information has been archived as it is now out of date. For current information please go to")
    assert page.has_css?("time[datetime='#{@content_item['withdrawn_notice']['withdrawn_at']}']")
  end

  test "historically political detailed guide" do
    setup_and_visit_content_item("political_detailed_guide")

    within ".govuk-notification-banner__content" do
      assert page.has_text?("This was published under the 2010 to 2015 Conservative and Liberal Democrat coalition government")
    end
  end

  test "detailed guide that only applies to a set of nations" do
    setup_and_visit_content_item("national_applicability_detailed_guide")
    assert_has_devolved_nations_component("Applies to England")
  end

  test "detailed guide that only applies to a set of nations, with alternative urls" do
    setup_and_visit_content_item("national_applicability_alternative_url_detailed_guide")
    assert_has_devolved_nations_component("Applies to England, Scotland and Wales", [
      {
        text: "Guidance for Northern Ireland",
        alternative_url: "http://www.dardni.gov.uk/news-dard-pa022-a-13-new-procedure-for",
      },
    ])
  end

  test "translated detailed guide" do
    setup_and_visit_content_item("translated_detailed_guide")

    assert_has_component_title(@content_item["title"])
    assert page.has_text?(@content_item["description"])

    assert page.has_css?(".gem-c-translation-nav")
  end

  test "renders a contents list" do
    setup_and_visit_content_item("detailed_guide")
    assert page.has_css?(".gem-c-contents-list")
  end

  test "renders without contents list if it has fewer than 3 items" do
    setup_and_visit_content_item("national_applicability_alternative_url_detailed_guide")
    assert_not page.has_css?(".gem-c-contents-list")
  end

  test "conditionally renders a logo" do
    setup_and_visit_content_item("england-2014-to-2020-european-structural-and-investment-funds")

    assert page.has_css?(".metadata-logo[alt='European structural investment funds']")
  end

  test "renders FAQ structured data" do
    setup_and_visit_content_item("detailed_guide")
    faq_schema = find_structured_data(page, "FAQPage")

    assert_equal faq_schema["name"], @content_item["title"]
    assert_not_equal faq_schema["mainEntity"], []
  end

  test "renders with the single page notification button" do
    setup_and_visit_content_item("detailed_guide")
    assert page.has_css?(".gem-c-single-page-notification-button")
  end

  test "does not render the single page notification button on exempt pages" do
    setup_and_visit_notification_exempt_page("detailed_guide")
    assert_not page.has_css?(".gem-c-single-page-notification-button")
  end
end
