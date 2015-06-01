require 'test_helper'

class CheckLinksControllerTest < ActionController::TestCase
  setup do
    @check_link = check_links(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:check_links)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create check_link" do
    assert_difference('CheckLink.count') do
      post :create, check_link: { checed_url: @check_link.checed_url, errors_found: @check_link.errors_found }
    end

    assert_redirected_to check_link_path(assigns(:check_link))
  end

  test "should show check_link" do
    get :show, id: @check_link
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @check_link
    assert_response :success
  end

  test "should update check_link" do
    patch :update, id: @check_link, check_link: { checed_url: @check_link.checed_url, errors_found: @check_link.errors_found }
    assert_redirected_to check_link_path(assigns(:check_link))
  end

  test "should destroy check_link" do
    assert_difference('CheckLink.count', -1) do
      delete :destroy, id: @check_link
    end

    assert_redirected_to check_links_path
  end
end
