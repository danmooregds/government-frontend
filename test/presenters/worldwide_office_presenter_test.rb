require "presenter_test_helper"

class WorldwideOfficePresenterTest < PresenterTestCase
  def schema_name
    "worldwide_office"
  end

  test "presents the title" do
    assert_equal schema_item["title"], presented_item.title
  end
end
