# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::OrphanedAuthors do
  let(:script) { described_class.new }

  context "with results" do
    let!(:author) { create :author }

    specify { expect(script.results).to eq [author] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:author) { create :author }
    let!(:author_name) { create :author_name, author: author }

    specify do
      expect { create :any_reference, author_names: [author_name] }.
        to change { script.results }.to([])
    end
  end
end
