require 'test_helper'

class AdjustmentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:adjustments)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_adjustment
    assert_difference('Adjustment.count') do
      post :create, :adjustment => { }
    end

    assert_redirected_to adjustment_path(assigns(:adjustment))
  end

  def test_should_show_adjustment
    get :show, :id => adjustments(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => adjustments(:one).id
    assert_response :success
  end

  def test_should_update_adjustment
    put :update, :id => adjustments(:one).id, :adjustment => { }
    assert_redirected_to adjustment_path(assigns(:adjustment))
  end

  def test_should_destroy_adjustment
    assert_difference('Adjustment.count', -1) do
      delete :destroy, :id => adjustments(:one).id
    end

    assert_redirected_to adjustments_path
  end
end
