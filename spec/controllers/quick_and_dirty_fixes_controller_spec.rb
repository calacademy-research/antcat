# frozen_string_literal: true

require 'rails_helper'

describe QuickAndDirtyFixesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(post(:replace_missing_tags, params: { history_item_id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor", as: :helper do
      specify { expect(post(:delete_history_item, params: { history_item_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:flag_as_original_combination, params: { taxon_id: 1 })).to have_http_status :forbidden }

      specify do
        expect(post(:update_current_taxon_id, params: { taxon_id: 1, new_current_taxon_id: 2 })).
          to have_http_status :forbidden
      end
    end
  end

  describe "POST force_remove_pages_from_taxac_tags", as: :helper do
    let(:taxon) { create :any_taxon }
    let!(:history_item) { create :history_item, :taxt }

    before do
      history_item.update_columns(taxt: %({#{Taxt::TAXAC_TAG} #{taxon.id}}: 12 "+alert(1)+" '</script><img src=x onerror=1>))
    end

    it "does not interpolate the taxt into the JavaScript response" do
      post :force_remove_pages_from_taxac_tags, params: { history_item_id: history_item.id }

      body = response.body
      expect(body).to start_with 'AntCat.notifySuccess("Force-removed pages from taxac tags: '
      expect(body).not_to include '"+alert', '<', '>'

      message = JSON.parse(body[/\AAntCat\.notifySuccess\((.*)\);\z/m, 1])
      expect(message).to include "&quot;+alert(1)+&quot;", "&lt;img src=x onerror=1&gt;"
      expect(message).not_to include "<img"
    end
  end
end
