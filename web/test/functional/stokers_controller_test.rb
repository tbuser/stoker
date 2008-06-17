require File.dirname(__FILE__) + '/../test_helper'

class StokersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stokers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_stoker
    assert_difference('Stoker.count') do
      post :create, :stoker => { }
    end

    assert_redirected_to stoker_path(assigns(:stoker))
  end

  def test_should_show_stoker
    get :show, :id => stokers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => stokers(:one).id
    assert_response :success
  end

  def test_should_update_stoker
    put :update, :id => stokers(:one).id, :stoker => { }
    assert_redirected_to stoker_path(assigns(:stoker))
  end

  def test_should_destroy_stoker
    assert_difference('Stoker.count', -1) do
      delete :destroy, :id => stokers(:one).id
    end

    assert_redirected_to stokers_path
  end
end
