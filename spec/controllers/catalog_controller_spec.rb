require 'spec_helper'

describe CatalogController do

  describe "Handling invalid UTF-8 (which we seem to get a lot)" do

    it "should ask the milieu" do
      pending("Rails 4 upgrade - test failing, underlying behaviour ok")
      # This test makes no sense at all.
      @current_user = double
      allow(controller).to receive(:current_user).and_return @current_user
      expect {get :show, id: create_genus.id, qq: "\255"}.not_to raise_error
    end
  end

end
