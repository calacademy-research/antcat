# frozen_string_literal: true

require 'rails_helper'

describe Citation do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_one(:protonym).dependent(:destroy) }
    it { is_expected.to belong_to(:reference).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :pages }
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:pages) }
  end

  describe 'scopes' do
    describe '.order_by_pages' do
      let(:reference) { create :any_reference }

      before do
        create :citation, reference: reference, pages: '101'
        create :citation, reference: reference, pages: '11'
        create :citation, reference: reference, pages: '301-302'
        create :citation, reference: reference, pages: '301'
      end

      it 'sorts in natural order' do
        expect(described_class.order_by_pages.pluck(:pages)).to eq ['11', '101', '301', '301-302']
      end
    end
  end
end
