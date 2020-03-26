# frozen_string_literal: true

require 'rails_helper'

describe Tooltips::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:tooltip) { create :tooltip }

    specify { expect(get(:show, params: { tooltip_id: tooltip.id })).to render_template :show }
  end
end
