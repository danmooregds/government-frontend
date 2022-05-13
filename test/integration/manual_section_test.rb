require "test_helper"

class ManualSectionTest < ActionDispatch::IntegrationTest
  test "page renders correctly" do
    setup_and_visit_manual_section

    assert_has_component_title(@content_item["title"])
    assert page.has_text?(@content_item["description"])
  end

  test "renders contextual breadcrumbs from parent manuals tagging" do
    setup_and_visit_manual_section
    manual_topic = @manual["links"]["topics"].first

    within ".gem-c-contextual-breadcrumbs" do
      assert page.has_link?(manual_topic["title"], href: manual_topic["base_path"])
    end
  end

  test "renders document heading" do
    setup_and_visit_manual_section

    within ".govuk-heading-l" do
      assert page.has_text?(@manual["title"])
    end
  end

  test "renders manual specific breadcrumbs" do
    setup_and_visit_manual_section

    manual_specific_breadcrumbs = page.all(".gem-c-breadcrumbs")[1]
    within manual_specific_breadcrumbs do
      assert page.has_link?(I18n.t("manuals.breadcrumb_contents"), href: @manual["base_path"])
    end
  end

  test "renders sections accordion" do
    setup_and_visit_manual_section

    assert page.has_css?(".gem-c-accordion")

    accordion_sections = page.all(".govuk-accordion__section")
    assert_equal 7, accordion_sections.count

    within accordion_sections[0] do
      assert page.has_text?("Designing content, not creating copy")
    end
  end

  test "renders expanded sections if visually expanded " do
    content_item = get_content_example("what-is-content-design")
    content_item["details"]["visually_expanded"] = true

    setup_and_visit_manual_section(content_item)

    within ".manual-body" do
      assert_equal 7, page.all("h2").count
      first_section_heading = page.all("h2").first

      assert_equal "Designing content, not creating copy", first_section_heading.text
    end
  end

  def setup_and_visit_manual_section(content_item = get_content_example("what-is-content-design"))
    @manual = get_content_example_by_schema_and_name("manual", "content-design")
    @content_item = content_item
    manual_base_path = @content_item["links"]["manual"].first["base_path"]

    stub_content_store_has_item(manual_base_path, @manual.to_json)

    stub_content_store_has_item(@content_item["base_path"], @content_item.to_json)
    visit_with_cachebust((@content_item["base_path"]).to_s)
  end
end
