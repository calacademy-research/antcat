# frozen_string_literal: true

require 'rails_helper'

describe Catalog::BoltonController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:show, params: { id: 1 })).to redirect_to_signin_form }
    end
  end
end
