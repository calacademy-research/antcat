require 'spec_helper'

describe Changes::UndosController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:show, params: { change_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { change_id: 1 })).to have_http_status :forbidden }
    end
  end
end
