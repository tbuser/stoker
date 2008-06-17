require File.dirname(__FILE__) + '/../test_helper'

class SensorsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:sensors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_sensor
    assert_difference('Sensor.count') do
      post :create, :sensor => { }
    end

    assert_redirected_to sensor_path(assigns(:sensor))
  end

  def test_should_show_sensor
    get :show, :id => sensors(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => sensors(:one).id
    assert_response :success
  end

  def test_should_update_sensor
    put :update, :id => sensors(:one).id, :sensor => { }
    assert_redirected_to sensor_path(assigns(:sensor))
  end

  def test_should_destroy_sensor
    assert_difference('Sensor.count', -1) do
      delete :destroy, :id => sensors(:one).id
    end

    assert_redirected_to sensors_path
  end
end
