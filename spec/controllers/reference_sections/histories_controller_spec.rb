require 'spec_helper'

describe ReferenceSections::HistoriesController do
  describe "GET show" do
    let!(:reference_section) { create :reference_section }

    specify { expect(get(:show, params: { reference_section_id: reference_section.id })).to render_template :show }
  end
end
