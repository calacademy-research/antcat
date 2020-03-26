require 'rails_helper'

describe References::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:reference) { create :article_reference }

    specify { expect(get(:show, params: { reference_id: reference.id })).to render_template :show }
  end
end
