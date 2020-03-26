# frozen_string_literal: true

require 'rails_helper'

describe WikiPages::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:wiki_page) { create :wiki_page }

    specify { expect(get(:show, params: { wiki_page_id: wiki_page.id })).to render_template :show }
  end
end
