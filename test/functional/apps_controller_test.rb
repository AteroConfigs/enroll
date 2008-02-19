require File.dirname(__FILE__) + '/../test_helper'

# make sure the secret for request forgery protection is set (views will
# explicitly use the form_authenticity_token method which will fail otherwise)
AppsController.request_forgery_protection_options[:secret] = 'test_secret'

class AppsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    get :index, :format => 'ext_json'
    assert_response :success
    assert_not_nil assigns(:apps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_app
    assert_difference('App.count') do
      xhr :post, :create, :format => 'ext_json', :app => { }
    end

    assert_not_nil flash[:notice]
    assert_response :success
  end

  def test_should_show_app
    get :show, :id => apps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => apps(:one).id
    assert_response :success
  end

  def test_should_update_app
    xhr :put, :update, :format => 'ext_json', :id => apps(:one).id, :app => { }
    assert_not_nil flash[:notice]
    assert_response :success
  end

  def test_should_destroy_app
    assert_difference('App.count', -1) do
      xhr :delete, :destroy, :id => apps(:one).id
    end

    assert_response :success
  end
end
