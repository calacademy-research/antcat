# frozen_string_literal: true

require 'rails_helper'

describe References::Key do
  subject(:key) { described_class.new(reference) }

  describe "#key_with_suffixed_year" do
    context 'when no authors' do
      let(:reference) { create :any_reference, :with_author_name, year: 1970, year_suffix: 'a' }

      specify do
        expect { reference.author_names = [] }.to change { key.key_with_suffixed_year }.to('[no authors], 1970a')
      end
    end

    context 'when one author' do
      let(:reference) { create :any_reference, author_string: 'Bolton, B.', year: 1970, year_suffix: 'a' }

      specify { expect(key.key_with_suffixed_year).to eq 'Bolton, 1970a' }
    end

    context 'when two authors' do
      let(:reference) { create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.'], year: 1970, year_suffix: 'a' }

      specify { expect(key.key_with_suffixed_year).to eq 'Bolton & Fisher, 1970a' }
    end

    context 'when three authors' do
      let(:reference) do
        create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.', 'Ward, P.S.'], year: 1970, year_suffix: 'a'
      end

      specify { expect(key.key_with_suffixed_year).to eq 'Bolton <i>et al.</i>, 1970a' }
      specify { expect(key.key_with_suffixed_year.html_safe?).to eq true }
    end
  end

  describe "#key_with_year" do
    let(:reference) { create :any_reference, author_string: 'Bolton', year: 1885, year_suffix: 'g' }

    it "doesn't include the year ordinal" do
      expect(key.key_with_year).to eq 'Bolton, 1885'
    end
  end
end
