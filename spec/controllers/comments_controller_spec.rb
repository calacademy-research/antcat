require 'spec_helper'

describe CommentsController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:index)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(post(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end
end
