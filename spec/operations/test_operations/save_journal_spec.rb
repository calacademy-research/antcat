# frozen_string_literal: true

require 'rails_helper'

describe TestOperations::SaveJournal do
  let!(:journal) { create :journal }

  describe "unsuccessful case" do
    subject(:operation) { described_class.new(journal, '') }

    it_behaves_like "an unsuccessful save journal operation" do
      let(:records_to_not_update) { [journal] }
    end
  end

  describe "successful case" do
    subject(:operation) { described_class.new(journal, 'Jonkerz Quarterly') }

    it_behaves_like "a successful save journal operation" do
      let(:records_to_update) { [journal] }
    end
  end
end
