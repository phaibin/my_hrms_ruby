require 'test_helper'

class OvertimeStatesControllerTest < ActionController::TestCase
  setup do
    @overtime_state = overtime_states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:overtime_states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create overtime_state" do
    assert_difference('OvertimeState.count') do
      post :create, overtime_state: @overtime_state.attributes
    end

    assert_redirected_to overtime_state_path(assigns(:overtime_state))
  end

  test "should show overtime_state" do
    get :show, id: @overtime_state
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @overtime_state
    assert_response :success
  end

  test "should update overtime_state" do
    put :update, id: @overtime_state, overtime_state: @overtime_state.attributes
    assert_redirected_to overtime_state_path(assigns(:overtime_state))
  end

  test "should destroy overtime_state" do
    assert_difference('OvertimeState.count', -1) do
      delete :destroy, id: @overtime_state
    end

    assert_redirected_to overtime_states_path
  end
end
