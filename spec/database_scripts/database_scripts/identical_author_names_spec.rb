# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::IdenticalAuthorNames do
  let(:script) { described_class.new }

  context "with results" do
    let!(:bolton) { create :author_name, name: 'Bolton' }
    let!(:vazquez_accented) { create :author_name, name: 'Vázquez' }
    let!(:vazquez_unaccented) { create :author_name, name: 'Vazquez' }

    specify { expect(script.results).to eq ['Vázquez'] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:bolton) { create :author_name, name: 'Bolton' }

    specify { expect(script.results).to eq [] }
  end
end
