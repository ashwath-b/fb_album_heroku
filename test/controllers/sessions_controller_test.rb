require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get albums" do
    get :albums
    assert_response :success
  end

  test "should get photos" do
    get :photos
    assert_response :success
  end

  test "should get import" do
    get :import
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
