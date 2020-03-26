require 'rails_helper'

describe Institutions::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:institution) { create :institution }

    specify { expect(get(:show, params: { institution_id: institution.id })).to render_template :show }
  end
end
