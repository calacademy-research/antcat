require 'spec_helper'

describe IssuesController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:close, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:reopen, params: { id: 1 })).to redirect_to_signin_form }
    end
  end
end
