# frozen_string_literal: true

require 'rails_helper'

describe AuthorsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor", as: :helper do
      let!(:author) { create :author }

      it "cannot delete an author" do
        expect { delete(:destroy, params: { id: author.id }) }.not_to change { Author.count }
        expect(response).to have_http_status :forbidden
      end
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:author) { create :author }

    it 'deletes the author' do
      expect { delete(:destroy, params: { id: author.id }) }.to change { Author.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: author.id }) }.
        to change { Activity.where(event: Activity::DESTROY, trackable: author).count }.by(1)
    end
  end
end
