require 'spec_helper'

describe CatalogController do

  describe "Handling invalid UTF-8 (which we seem to get a lot)" do
    it "should ask the milieu" do
      @current_user = double
      controller.stub(:current_user).and_return @current_user
      -> {get :show, id: create_genus.id, qq: "\255"}.should_not raise_error
    end
  end

end
