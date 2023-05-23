require "presenter_test_helper"

class WorldwideOfficePresenterTest < PresenterTestCase
  def schema_name
    "worldwide_office"
  end

  test "presents the title" do
    assert_equal schema_item["title"], presented_item.title
  end

  test "presents the contact as an instance of #{WorldwideOrganisation::LinkedContactPresenter}" do
    assert presented_item.contact.is_a?(WorldwideOrganisation::LinkedContactPresenter)
  end
end
