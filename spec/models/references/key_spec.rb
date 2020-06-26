# frozen_string_literal: true

require 'rails_helper'

describe References::Key do
  subject(:key) { described_class.new(reference) }

  describe "#keey" do
    let(:bolton) { create :author_name, name: 'Bolton, B.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.' }

    context 'when no authors' do
      let(:reference) { create :any_reference, :with_author_name, citation_year: '1970a' }

      specify do
        expect { reference.author_names = [] }.to change { key.keey }.to('[no authors], 1970a')
      end
    end

    context 'when one author' do
      let(:reference) { create :any_reference, author_names: [bolton], citation_year: '1970a' }

      specify { expect(key.keey).to eq 'Bolton, 1970a' }
    end

    context 'when two authors' do
      let(:reference) { create :any_reference, author_names: [bolton, fisher], citation_year: '1970a' }

      specify { expect(key.keey).to eq 'Bolton & Fisher, 1970a' }
    end

    context 'when three authors' do
      let(:reference) do
        ward = create :author_name, name: 'Ward, P.S.'
        create :any_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
      end

      specify { expect(key.keey).to eq 'Bolton <i>et al.</i>, 1970a' }
      specify { expect(key.keey.html_safe?).to eq true }
    end
  end

  describe "#key_with_year" do
    let(:reference) { create :any_reference, author_string: 'Bolton', citation_year: '1885g' }

    it "doesn't include the year ordinal" do
      expect(key.key_with_year).to eq 'Bolton, 1885'
    end
  end
end
