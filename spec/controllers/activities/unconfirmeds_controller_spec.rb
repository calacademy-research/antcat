# frozen_string_literal: true

require 'rails_helper'

describe Activities::UnconfirmedsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:show)).to redirect_to_signin_form }
    end
  end

  describe "GET show", as: :user do
    specify { expect(get(:show)).to render_template :show }
  end
end
