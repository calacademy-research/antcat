# frozen_string_literal: true

require 'rails_helper'

describe Names::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:name) { create :family_name }

    specify { expect(get(:show, params: { name_id: name.id })).to render_template :show }
  end
end
