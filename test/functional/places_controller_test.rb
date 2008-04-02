require File.dirname(__FILE__) + '/../test_helper'
require 'places_controller'

# Re-raise errors caught by the controller.
class PlacesController; def rescue_action(e) raise e end; end

class PlacesControllerTest < Test::Unit::TestCase
  fixtures :places

  def setup
    @controller = PlacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:places)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_place
    old_count = Place.count
    post :create, :place => { }
    assert_equal old_count+1, Place.count
    
    assert_redirected_to place_path(assigns(:place))
  end

  def test_should_show_place
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_place
    put :update, :id => 1, :place => { }
    assert_redirected_to place_path(assigns(:place))
  end
  
  def test_should_destroy_place
    old_count = Place.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Place.count
    
    assert_redirected_to places_path
  end
end
