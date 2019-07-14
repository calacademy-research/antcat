require 'spec_helper'

describe TaxonHistoryItems::HistoriesController do
  describe "GET show" do
    let!(:taxon_history_item) { create :taxon_history_item }

    specify { expect(get(:show, params: { taxon_history_item_id: taxon_history_item.id })).to render_template :show }
  end
end
