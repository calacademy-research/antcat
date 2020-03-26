# frozen_string_literal: true

require 'rails_helper'

describe Issues::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:issue) { create :issue }

    specify { expect(get(:show, params: { issue_id: issue.id })).to render_template :show }
  end
end
