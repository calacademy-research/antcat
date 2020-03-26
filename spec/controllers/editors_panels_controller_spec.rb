require 'rails_helper'

describe EditorsPanelsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:index)).to redirect_to_signin_form }
    end
  end
end
