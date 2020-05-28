# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ChildrenController do
  describe "GET show", as: :visitor do
    let(:taxon) { create :family }

    specify { expect(get(:show, params: { taxa_id: taxon.id })).to render_template :show }
  end
end
