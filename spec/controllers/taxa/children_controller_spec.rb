require 'rails_helper'

describe Taxa::ChildrenController do
  describe "GET show" do
    let(:taxon) { create :family }

    specify { expect(get(:show, params: { taxa_id: taxon.id })).to render_template :show }
  end
end
