require 'rails_helper'

describe Protonyms::SoftValidationsController do
  describe "GET show" do
    let!(:protonym) { create :protonym }

    specify { expect(get(:show, params: { protonym_id: protonym.id })).to render_template :show }
  end
end
