require 'spec_helper'

describe DefaultReferencesController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(post(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end
end
