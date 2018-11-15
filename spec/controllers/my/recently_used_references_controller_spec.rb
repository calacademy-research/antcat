require 'spec_helper'

describe My::RecentlyUsedReferencesController do
  describe "GET index" do
    let(:recently_used_references) { [] }

    it "calls `Autocomplete::FormatLinkableReferences`" do
      expect(Autocomplete::FormatLinkableReferences).
        to receive(:new).with(recently_used_references).and_call_original
      get :index
    end
  end
end
