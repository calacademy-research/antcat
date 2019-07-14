require 'spec_helper'

describe Activities::UnconfirmedsController do
  describe "GET show" do
    specify { expect(get(:show)).to render_template :show }
  end
end
