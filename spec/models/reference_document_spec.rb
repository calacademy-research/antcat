# frozen_string_literal: true

require 'rails_helper'

describe ReferenceDocument do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:reference).required }
  end

  describe 'validations' do
    it { is_expected.to validate_absence_of(:url).on(:create) }

    describe '#ensure_file_or_url_present' do
      context 'when `url` and `file_file_name` are both blank' do
        let(:document) { described_class.new(url: nil, file_file_name: nil) }

        specify do
          expect(document.valid?).to eq false
          expect(document.errors.full_messages).to include "URL and uploaded file cannot both be blank"
        end
      end

      context 'when `url` and `file_file_name` are both present' do
        let(:document) { described_class.new(url: "http://ancat.org/file.pdf", file_file_name: 'file.pdf') }

        specify do
          expect(document.valid?).to eq false
          expect(document.errors.full_messages).to include "URL and uploaded file cannot both be present"
        end
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:url) }
  end

  describe "#routed_url" do
    it "creates the URL for an uploaded file so that it goes to our controller" do
      document = create :reference_document, :with_reference, file_file_name: '1.pdf'
      expect(document.reload.routed_url).to eq "http://antcat.org/documents/#{document.id}/1.pdf"
    end

    context "when the file isn't hosted by us" do
      let(:document) { described_class.new(url: 'foo') }

      specify do
        expect(document.url).to eq 'foo'
        expect(document.routed_url).to eq 'foo'
      end
    end

    context "when the file is hosted by us" do
      let(:document) { described_class.create!(file_file_name: 'foo', reference: create(:any_reference)) }

      specify do
        expect(document.url).to eq nil
        expect(document.routed_url).to eq "http://antcat.org/documents/#{document.id}/foo"
      end
    end
  end

  describe "#actual_url" do
    let!(:reference_document) { create :reference_document, :with_reference, :with_deprecated_url }

    it "simply is the `url`" do
      expect(reference_document.reload.actual_url).to eq reference_document.url
    end
  end
end
