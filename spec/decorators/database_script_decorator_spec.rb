require 'rails_helper'

describe DatabaseScriptDecorator do
  let(:decorated) { database_script.decorate }

  describe '.format_tags' do
    specify do
      expect(described_class.format_tags(['new!'])).to eq '<span class="label rounded-badge">new!</span>'
    end
  end

  describe "#format_tags" do
    let(:database_script) { DatabaseScripts::OrphanedProtonyms.new }

    specify { expect(decorated.format_tags).to eq '<span class="white-label rounded-badge">list</span>' }
  end

  describe "#format_topic_areas" do
    let(:database_script) { DatabaseScripts::OrphanedProtonyms.new }

    specify { expect(decorated.format_topic_areas).to eq "Protonyms" }
  end

  describe "#github_url" do
    let(:database_script) { DatabaseScripts::DatabaseTestScript.new }

    specify do
      expect(decorated.github_url).
        to eq "https://github.com/calacademy-research/antcat/blob/master/app/database_scripts/database_scripts/database_test_script.rb"
    end
  end
end
