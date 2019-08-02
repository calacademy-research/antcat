require 'spec_helper'

describe References::LinkableAutocompletesController do
  describe "GET show" do
    let(:q) { "bolton" }

    it "calls `Autocomplete::AutocompleteLinkableReferences`" do
      expect(Autocomplete::AutocompleteLinkableReferences).to receive(:new).with(q).and_call_original
      get :show, params: { q: q, format: :json }
    end
  end
end
