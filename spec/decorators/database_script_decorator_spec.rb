# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScriptDecorator do
  subject(:decorated) { database_script.decorate }

  describe '.format_tags' do
    specify do
      expect(described_class.format_tags(['new!'])).to eq '<span class="label rounded-badge">new!</span>'
    end
  end

  describe "#format_tags" do
    context 'when testing with a real script' do
      let(:database_script) { DatabaseScripts::TaxaWithSameName.new }

      specify { expect(decorated.format_tags).to eq '<span class="white-label rounded-badge">list</span>' }
    end

    context "when script is in the 'main' section" do
      let(:database_script) { DatabaseScripts::TaxaWithSameName.new }

      before do
        def database_script.section
          DatabaseScripts::Tagging::MAIN_SECTION
        end
      end

      it "does not include 'main' in the tags" do
        expect(decorated.format_tags).to eq ""
      end
    end

    context 'when script is an `UnfoundDatabaseScript`' do
      let(:database_script) { DatabaseScripts::UnfoundDatabaseScript.new("BestPizzas") }
      let(:decorated) { described_class.new(database_script) }

      specify { expect(decorated.format_tags).to eq '' }
    end
  end

  describe '#soft_validated?' do
    it 'returns true if the script is used for taxon soft-validations' do
      expect(SoftValidations::TAXA_DATABASE_SCRIPTS_TO_CHECK.first.new.decorate.soft_validated?).to eq true
      expect(DatabaseScripts::ProtonymsWithSameName.new.decorate.soft_validated?).to eq false
    end
  end

  describe "#github_url" do
    let(:database_script) { DatabaseScripts::DatabaseTestScript.new }

    specify do
      expect(decorated.github_url).
        to eq "https://github.com/calacademy-research/antcat/blob/master/app/database_scripts/database_scripts/database_test_script.rb"
    end
  end
end
