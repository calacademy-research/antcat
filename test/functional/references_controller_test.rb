require 'test_helper'

class ReferencesControllerTest < ActionController::TestCase
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Reference.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Reference.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to reference_url(assigns(:reference))
  end
  
  def test_show
    get :show, :id => Reference.first
    assert_template 'show'
  end
  
  def test_update_invalid
    Reference.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Reference.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Reference.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Reference.first
    assert_redirected_to reference_url(assigns(:reference))
  end
  
  def test_destroy
    reference = Reference.first
    delete :destroy, :id => reference
    assert_redirected_to references_url
    assert !Reference.exists?(reference.id)
  end
  
  def test_index
    get :index
    assert_template 'index'
  end
end
