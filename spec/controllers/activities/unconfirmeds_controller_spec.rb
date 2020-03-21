require 'rails_helper'

describe Activities::UnconfirmedsController do
  describe "GET show", as: :visitor do
    specify { expect(get(:show)).to render_template :show }
  end
end
