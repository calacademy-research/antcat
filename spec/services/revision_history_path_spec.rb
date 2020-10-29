# frozen_string_literal: true

require 'rails_helper'

describe RevisionHistoryPath do
  describe "#call" do
    specify { expect(described_class['Institution', 1]).to eq "/institutions/1/history" }
    specify { expect(described_class['Name', 1]).to eq "/names/1/history" }
    specify { expect(described_class['Protonym', 1]).to eq "/protonyms/1/history" }
    specify { expect(described_class['Reference', 1]).to eq "/references/1/history" }
    specify { expect(described_class['ReferenceSection', 1]).to eq "/reference_sections/1/history" }
    specify { expect(described_class['Taxon', 1]).to eq "/catalog/1/history" }
    specify { expect(described_class['HistoryItem', 1]).to eq "/history_items/1/history" }
    specify { expect(described_class['Tooltip', 1]).to eq "/tooltips/1/history" }
    specify { expect(described_class['WikiPage', 1]).to eq "/wiki_pages/1/history" }
  end
end
