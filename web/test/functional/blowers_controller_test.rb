require File.dirname(__FILE__) + '/../test_helper'

class BlowersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:blowers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_blower
    assert_difference('Blower.count') do
      post :create, :blower => { }
    end

    assert_redirected_to blower_path(assigns(:blower))
  end

  def test_should_show_blower
    get :show, :id => blowers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => blowers(:one).id
    assert_response :success
  end

  def test_should_update_blower
    put :update, :id => blowers(:one).id, :blower => { }
    assert_redirected_to blower_path(assigns(:blower))
  end

  def test_should_destroy_blower
    assert_difference('Blower.count', -1) do
      delete :destroy, :id => blowers(:one).id
    end

    assert_redirected_to blowers_path
  end
end
