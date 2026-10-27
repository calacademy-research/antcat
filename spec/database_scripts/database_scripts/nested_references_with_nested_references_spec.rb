# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::NestedReferencesWithNestedReferences do
  let(:script) { described_class.new }

  context "with results" do
    let!(:nesting_reference) { create :nested_reference, pagination: 'Pp. 10-20 in:' }
    let!(:reference) { create :nested_reference, nesting_reference: nesting_reference, pagination: 'P. 12 in:' }

    specify { expect(script.results).to eq [reference] }

    it "shows the pagination of each reference next to it" do
      rendered = DatabaseScripts::Render.new(script, {}).call
      expect(rendered).to include 'Pp. 10-20 in:'
    end

    context "when a pagination is missing" do
      before do
        reference.update_columns(pagination: nil)
      end

      it_behaves_like "a database script with renderable results"
    end
  end
end
