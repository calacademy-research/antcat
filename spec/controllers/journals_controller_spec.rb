require 'spec_helper'

describe JournalsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET autocomplete" do
    let(:term) { "zootaxa" }

    it "calls `Autocomplete::AutocompleteJournals`" do
      expect(Autocomplete::AutocompleteJournals).to receive(:new).with(term).and_call_original
      get :autocomplete, params: { term: term, format: :json }
    end
  end
end
