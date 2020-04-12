# frozen_string_literal: true

require 'rails_helper'

describe ReferenceObserver do
  describe "`NestedReference`s" do
    let(:reference) { create :any_reference }

    context "when a nesting_reference is changed" do
      let(:nestee) { create :nested_reference, nesting_reference: reference }

      before do
        reference.reload
        nestee.reload
        References::Cache::Regenerate[reference]
        References::Cache::Regenerate[nestee]
      end

      it "invalidates the cache for itself and its nestees" do
        expect(reference.plain_text_cache).not_to eq nil
        expect(nestee.plain_text_cache).not_to eq nil

        reference.update!(title: "New Title")

        expect(reference.reload.plain_text_cache).to eq nil
        expect(nestee.reload.plain_text_cache).to eq nil
      end
    end

    describe "Handling a network" do
      let!(:nesting_reference) { create :article_reference }
      let!(:nested_reference) { create :nested_reference, nesting_reference: nesting_reference }
      let!(:reference_author_name) do
        create :reference_author_name, reference: nesting_reference,author_name: create(:author_name)
      end

      before do
        References::Cache::Regenerate[nesting_reference]
        nesting_reference.reload

        References::Cache::Regenerate[nested_reference]
        nested_reference.reload
      end

      it "invalidates each member of the network" do
        expect(nesting_reference.plain_text_cache).not_to eq nil
        expect(nested_reference.plain_text_cache).not_to eq nil

        reference_author_name.position = 4
        reference_author_name.save!

        nesting_reference.reload
        nested_reference.reload

        expect(nesting_reference.plain_text_cache).to eq nil
        expect(nested_reference.plain_text_cache).to eq nil
      end
    end
  end
end
