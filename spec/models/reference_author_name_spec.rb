# frozen_string_literal: true

require 'rails_helper'

describe ReferenceAuthorName do
  it { is_expected.to be_versioned }

  describe 'callbacks' do
    describe '#invalidate_reference_caches!' do
      let!(:reference) { create :any_reference }
      let!(:reference_author_names) { reference.reference_author_names.first }

      before do
        References::Cache::Regenerate[reference]
      end

      context "when a `ReferenceAuthorName` is added" do
        it "invalidates caches for its references" do
          expect { reference.reference_author_names.create!(author_name: create(:author_name)) }.
            to change { reference.reload.plain_text_cache }.to(nil)
        end
      end

      context "when a `ReferenceAuthorName` is updated" do
        it "invalidates caches for its references" do
          expect { reference_author_names.update!(position: 999) }.
            to change { reference.reload.plain_text_cache }.to(nil)
        end
      end

      context "when a `ReferenceAuthorName` is destroyed" do
        it "invalidates caches for its references" do
          expect { reference_author_names.destroy! }.to change { reference.reload.plain_text_cache }.to(nil)
        end
      end
    end
  end
end
