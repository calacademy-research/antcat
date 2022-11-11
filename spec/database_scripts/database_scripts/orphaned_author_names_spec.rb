# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::OrphanedAuthorNames do
  let(:script) { described_class.new }

  context "with results" do
    let!(:author_name) { create :author_name }

    specify { expect(script.results).to eq [author_name] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:author_name) { create :author_name }

    specify do
      expect { create :any_reference, author_names: [author_name] }.
        to change { script.results }.to([])
    end
  end
end
