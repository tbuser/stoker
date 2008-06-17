require File.dirname(__FILE__) + '/../test_helper'

class CooksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cooks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cook
    assert_difference('Cook.count') do
      post :create, :cook => { }
    end

    assert_redirected_to cook_path(assigns(:cook))
  end

  def test_should_show_cook
    get :show, :id => cooks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => cooks(:one).id
    assert_response :success
  end

  def test_should_update_cook
    put :update, :id => cooks(:one).id, :cook => { }
    assert_redirected_to cook_path(assigns(:cook))
  end

  def test_should_destroy_cook
    assert_difference('Cook.count', -1) do
      delete :destroy, :id => cooks(:one).id
    end

    assert_redirected_to cooks_path
  end
end
