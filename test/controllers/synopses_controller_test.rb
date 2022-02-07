require "test_helper"

class SynopsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @synopsis = synopses(:one)
  end

  test "should get index" do
    get synopses_url
    assert_response :success
  end

  test "should get new" do
    get new_synopsis_url
    assert_response :success
  end

  test "should create synopsis" do
    assert_difference('Synopsis.count') do
      post synopses_url, params: { synopsis: { comment: @synopsis.comment } }
    end

    assert_redirected_to synopsis_url(Synopsis.last)
  end

  test "should show synopsis" do
    get synopsis_url(@synopsis)
    assert_response :success
  end

  test "should get edit" do
    get edit_synopsis_url(@synopsis)
    assert_response :success
  end

  test "should update synopsis" do
    patch synopsis_url(@synopsis), params: { synopsis: { comment: @synopsis.comment } }
    assert_redirected_to synopsis_url(@synopsis)
  end

  test "should destroy synopsis" do
    assert_difference('Synopsis.count', -1) do
      delete synopsis_url(@synopsis)
    end

    assert_redirected_to synopses_url
  end
end
