# frozen_string_literal: true

require 'rails_helper'

describe Authors::MergesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { author_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { author_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { author_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :editor do
    let!(:author) { create :author }
    let!(:author_name) { create :author_name, author: author }

    it "does not merge an author into itself" do
      expect(Authors::Merge).not_to receive(:new)

      expect { post :create, params: { author_id: author.id, author_to_merge_id: author.id } }.
        not_to change { [Author.count, AuthorName.count] }
      expect(response).to redirect_to new_author_merges_path(author)
      expect(flash[:alert]).to eq described_class::CANNOT_MERGE_INTO_ITSELF
      expect(author_name.reload.author).to eq author
    end

    it "redirects when the author to merge is missing" do
      expect { post :create, params: { author_id: author.id } }.not_to change { Author.count }
      expect(response).to redirect_to new_author_merges_path(author)
    end
  end

  describe "GET show", as: :editor do
    let!(:author) { create :author }

    it "does not offer to merge an author into itself" do
      get :show, params: { author_id: author.id, author_to_merge_id: author.id }
      expect(response).to redirect_to new_author_merges_path(author)
    end
  end
end
