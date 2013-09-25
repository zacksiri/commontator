require 'test_helper'

module Commontator
  describe ThreadsController do
    before do
      setup_controller_spec
    end
    
    it 'wont show unless authorized' do
      get :show, :id => @thread.id, :use_route => :commontator
      assert_response 403
      
      sign_in @user
      get :show, :id => @thread.id, :use_route => :commontator
      assert_response 403
    end
    
    it 'must show if authorized' do
      commontable_path = Rails.application.routes.url_helpers.dummy_model_path(@commontable)
      sign_in @user
      
      @user.can_read = true
      get :show, :id => @thread.id, :use_route => :commontator
      assert_redirected_to commontable_path
      
      @user.can_read = false
      @user.can_edit = true
      get :show, :id => @thread.id, :use_route => :commontator
      assert_redirected_to commontable_path
      
      @user.can_edit = false
      @user.is_admin = true
      get :show, :id => @thread.id, :use_route => :commontator
      assert_redirected_to commontable_path
    end
    
    it 'wont close unless authorized and open' do
      patch :close, :id => @thread.id, :use_route => :commontator
      assert_response 403
      assigns(:thread).is_closed?.must_equal false
      
      sign_in @user
      patch :close, :id => @thread.id, :use_route => :commontator
      assert_response 403
      assigns(:thread).is_closed?.must_equal false
      
      @user.can_read = true
      patch :close, :id => @thread.id, :use_route => :commontator
      assert_response 403
      assigns(:thread).is_closed?.must_equal false
      
      @user.can_edit = true
      @thread.close.must_equal true
      patch :close, :id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must close if authorized and open' do
      sign_in @user
      
      @user.can_edit = true
      patch :close, :id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      assigns(:thread).is_closed?.must_equal true
      assigns(:thread).closer.must_equal @user
      
      assigns(:thread).reopen.must_equal true
      @user.can_edit = false
      @user.is_admin = true
      patch :close, :id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      assigns(:thread).is_closed?.must_equal true
      assigns(:thread).closer.must_equal @user
    end
    
    it 'wont reopen unless authorized and closed' do
      @thread.close.must_equal true
      patch :reopen, :id => @thread.id, :use_route => :commontator
      assert_response 403
      assigns(:thread).is_closed?.must_equal true
      
      sign_in @user
      patch :reopen, :id => @thread.id, :use_route => :commontator
      assert_response 403
      assigns(:thread).is_closed?.must_equal true
      
      @user.can_read = true
      patch :reopen, :id => @thread.id, :use_route => :commontator
      assert_response 403
      assigns(:thread).is_closed?.must_equal true
      
      @thread.reopen.must_equal true
      @user.can_edit = true
      patch :reopen, :id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.wont_be_empty
    end
    
    it 'must reopen if authorized and closed' do
      sign_in @user
      
      @thread.close.must_equal true
      @user.can_edit = true
      patch :reopen, :id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      assigns(:thread).is_closed?.must_equal false
      
      assigns(:thread).close.must_equal true
      @user.can_edit = false
      @user.is_admin = true
      patch :reopen, :id => @thread.id, :use_route => :commontator
      assert_redirected_to @thread
      assigns(:thread).errors.must_be_empty
      assigns(:thread).is_closed?.must_equal false
    end
  end
end
