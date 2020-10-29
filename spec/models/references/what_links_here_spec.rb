# frozen_string_literal: true

require 'rails_helper'

describe References::WhatLinksHere do
  subject(:what_links_here) { described_class.new(reference.reload) }

  let(:reference) { create :any_reference }

  context 'when there are no references' do
    specify { expect(what_links_here.all).to eq [] }
    specify { expect(what_links_here.any?).to eq false }
  end

  context 'when there are column references' do
    let!(:authorship) { create :citation, reference: reference }
    let!(:nested_reference) { create :nested_reference, nesting_reference: reference }
    let!(:type_name) { create :type_name, :by_subsequent_designation_of, reference: reference }

    specify do
      expect(what_links_here.all).to match_array [
        WhatLinksHereItem.new('citations',  :reference_id,         authorship.id),
        WhatLinksHereItem.new('references', :nesting_reference_id, nested_reference.id),
        WhatLinksHereItem.new('type_names', :reference_id,         type_name.id)
      ]
    end

    specify { expect(what_links_here.any?).to eq true }
  end

  context 'when there are taxt references' do
    describe "tag: `ref`" do
      let(:taxt_tag) { "{ref #{reference.id}}" }

      let!(:protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('taxon_history_items', :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
    end
  end
end
