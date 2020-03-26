require 'rails_helper'

describe Protonyms::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:protonym) { create :protonym }

    specify { expect(get(:show, params: { protonym_id: protonym.id })).to render_template :show }
  end
end
