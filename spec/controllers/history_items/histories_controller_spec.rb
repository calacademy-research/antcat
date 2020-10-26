# frozen_string_literal: true

require 'rails_helper'

describe HistoryItems::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:history_item) { create :history_item }

    specify { expect(get(:show, params: { history_item_id: history_item.id })).to render_template :show }
  end
end
