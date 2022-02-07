require "application_system_test_case"

class SynopsesTest < ApplicationSystemTestCase
  setup do
    @synopsis = synopses(:one)
  end

  test "visiting the index" do
    visit synopses_url
    assert_selector "h1", text: "Synopses"
  end

  test "creating a Synopsis" do
    visit synopses_url
    click_on "New Synopsis"

    fill_in "Comment", with: @synopsis.comment
    click_on "Create Synopsis"

    assert_text "Synopsis was successfully created"
    click_on "Back"
  end

  test "updating a Synopsis" do
    visit synopses_url
    click_on "Edit", match: :first

    fill_in "Comment", with: @synopsis.comment
    click_on "Update Synopsis"

    assert_text "Synopsis was successfully updated"
    click_on "Back"
  end

  test "destroying a Synopsis" do
    visit synopses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Synopsis was successfully destroyed"
  end
end
