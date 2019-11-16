require 'rails_helper'

describe AuthorsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "DELETE destroy" do
    let!(:author) { create :author }

    before { sign_in create(:user, :helper) }

    it 'deletes the author' do
      expect { delete(:destroy, params: { id: author.id }) }.to change { Author.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: author.id }) }.
        to change { Activity.where(action: :destroy, trackable: author).count }.by(1)
    end
  end
end
