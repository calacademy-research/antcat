# frozen_string_literal: true

# TODO: `described_class` requires a lot of non-required params to be passed in.

require 'rails_helper'

describe ReferenceForm do
  describe "#save" do
    describe "updating attributes" do
      let!(:reference) { create :article_reference }
      let(:params) do
        {
          author_names_string: reference.author_names_string,
          journal_name: reference.journal.name,
          bolton_key: "Smith 1858b"
        }
      end

      specify do
        expect { described_class.new(reference, params).save }.
          to change { reference.reload.bolton_key }.to(params[:bolton_key])
      end
    end

    describe "updating author names" do
      let!(:author_names) { [create(:author_name, name: "Batiatus, B.")] }
      let!(:reference) { create :article_reference, author_names: author_names }

      context "when author names have not changed" do
        let(:params) do
          {
            author_names_string: reference.author_names_string,
            journal_name: reference.journal.name
          }
        end

        it "does not create new `AuthorName`s for existing authors" do
          expect { described_class.new(reference, params).save }.to_not change { AuthorName.count }
        end

        it "reuses existing `ReferenceAuthorName`s" do
          expect { described_class.new(reference, params).save }.
            to_not change { reference.reload.reference_author_name_ids }
        end

        it "does not create any versions for the reference" do
          with_versioning do
            expect { described_class.new(reference, params).save }.
              to_not change { reference.versions.count }
          end
        end
      end

      context "when something has changed" do
        context "when author names have not changed" do
          let(:params) do
            {
              author_names_string: reference.author_names_string,
              journal_name: reference.journal.name,
              bolton_key: "Smith 1858b"
            }
          end

          it "creates a single version for the reference" do
            with_versioning do
              expect { described_class.new(reference, params).save }.
                to change { reference.versions.count }.by(1)
            end
          end
        end

        context "when an author name have been added" do
          let(:params) do
            {
              author_names_string: "Batiatus, B.; Glaber, G.",
              journal_name: reference.journal.name,
              bolton_key: "Smith 1858b"
            }
          end

          # TODO: Code was changed to make the spec pass, but that introduced a regression where
          # the `reference_author_names.position` was not reset (which `reference.author_names.clear` did).
          # See also "reversing author names".
          xit "creates a single version for the reference" do
            with_versioning do
              expect { described_class.new(reference, params).save }.
                to change { reference.versions.count }.by(1)
            end
          end

          it "updates `#author_names_string_cache`" do
            expect { described_class.new(reference, params).save }.
              to change { reference.reload.author_names_string_cache }.
              from('Batiatus, B.').to("Batiatus, B.; Glaber, G.")
          end
        end

        # TODO: Spec was added after a regression was introduced.
        # See also "creates a single version for the reference".
        describe "reordering author names" do
          let!(:author_names) do
            [
              create(:author_name, name: "Batiatus, B."),
              create(:author_name, name: "Glaber, G.")
            ]
          end
          let!(:reference) { create :article_reference, author_names: author_names }
          # TODO: Being extra explicit here since the class mutates the `params`.
          let(:original_author_names_string) { 'Batiatus, B.; Glaber, G.' }
          let(:reversed_author_names_string) { 'Glaber, G.; Batiatus, B.' }
          let(:reverse_authors_params) do
            {
              author_names_string: reversed_author_names_string,
              journal_name: reference.journal.name
            }
          end
          let(:restore_authors_params) do
            {
              author_names_string: original_author_names_string,
              journal_name: reference.journal.name
            }
          end

          it "saves author names in the given order " do
            expect { described_class.new(reference, reverse_authors_params).save }.
              to change { reference.reload.author_names_string_cache }.
              from(original_author_names_string).to(reversed_author_names_string)
          end
        end

        context "when more than one author names have been added" do
          let(:params) do
            {
              author_names_string: "Batiatus, B.; Glaber, G.; Borgia, C.",
              journal_name: reference.journal.name,
              bolton_key: "Smith 1858b"
            }
          end

          # TODO: We may want this. See `after_add: :refresh_author_names_caches`.
          xit "creates a single version for the reference" do
            with_versioning do
              expect { described_class.new(reference, params).save }.
                to change { reference.versions.count }.by(1)
            end
          end

          it "updates `#author_names_string_cache`" do
            expect { described_class.new(reference, params).save }.
              to change { reference.reload.author_names_string_cache }.
              from('Batiatus, B.').to("Batiatus, B.; Glaber, G.; Borgia, C.")
          end
        end

        context "when an author name has been removed" do
          let!(:author_names) do
            [
              create(:author_name, name: "Batiatus, B."),
              create(:author_name, name: "Glaber, G.")
            ]
          end
          let!(:reference) { create :article_reference, author_names: author_names }
          let(:params) do
            {
              author_names_string: "Batiatus, B.",
              journal_name: reference.journal.name,
              bolton_key: "Smith 1858b"
            }
          end

          it 'deletes orphaned `ReferenceAuthorName`s' do
            expect { described_class.new(reference, params).save }.
              to change { ReferenceAuthorName.count }.from(2).to(1)
          end

          it "updates `#author_names_string_cache`" do
            expect { described_class.new(reference, params).save }.
              to change { reference.reload.author_names_string_cache }.
              from('Batiatus, B.; Glaber, G.').to("Batiatus, B.")
          end
        end
      end
    end

    describe 'reference documents' do
      context 'when creating a reference' do
        context 'when no `file` or `url` is given' do
          let!(:reference) { build :article_reference }
          let(:params) do
            {
              author_names_string: "Batiatus, B.",
              journal_name: reference.journal.name,
              document_attributes: {
                url: "",
                public: '1'
              }
            }
          end

          it 'creates a reference (test spec)`' do
            expect { described_class.new(reference, params).save }.to change { Reference.count }
          end

          it 'does not create a new `ReferenceDocument`s' do
            expect { described_class.new(reference, params).save }.
              to_not change { ReferenceDocument.count }.from(0)
          end
        end

        context 'when a `file` or `url` is given' do
          let!(:reference) { build :article_reference }
          let(:params) do
            {
              author_names_string: "Batiatus, B.",
              journal_name: 'Zootaxa',
              bolton_key: 'Smith 1958',
              document_attributes: {
                url: "https://example.com/file.pdf",
                public: '1'
              }
            }
          end

          it 'creates a reference (test spec)`' do
            expect { described_class.new(reference, params).save }.to change { Reference.count }
          end

          it 'does creates a new `ReferenceDocument`' do
            expect { described_class.new(reference, params).save }.
              to change { ReferenceDocument.count }.from(0).to(1)
          end
        end
      end

      context 'when updating a reference' do
        let(:params) do
          {
            author_names_string: "Batiatus, B.",
            journal_name: reference.journal.name,
            title: "Should be updated",
            document_attributes: {
              url: "http://localhost/123.pdf",
              id: reference.document.id
            }
          }
        end

        context 'when reference has a document' do
          let!(:reference) { create :article_reference, :with_document }

          it 'does not create a new `ReferenceDocument`s' do
            expect(ReferenceDocument.count).to eq 1
            expect { described_class.new(reference, params).save }.
              to change { reference.reload.title }.to(params[:title])
            expect(ReferenceDocument.count).to eq 1
          end
        end
      end
    end

    describe "#cleanup_bolton_key" do
      let!(:reference) { create :article_reference }
      let(:params) do
        {
          author_names_string: reference.author_names_string,
          journal_name: reference.journal.name,
          bolton_key: "Smith & Wesson ,  1858:b"
        }
      end

      it 'removes unwanted characters' do
        expect { described_class.new(reference, params).save }.
          to change { reference.reload.bolton_key }.to("Smith Wesson 1858b")
      end
    end

    describe "duplicate checking" do
      let!(:original) { create :article_reference, :with_author_name }
      let(:params) do
        {
          author_names_string: original.author_names_string,
          journal_name: original.journal.name,
          citation_year: original.citation_year,
          title: original.title,
          series_volume_issue: original.series_volume_issue,
          pagination: original.pagination
        }
      end
      let!(:duplicate) { create :article_reference, author_names: original.author_names }

      context 'when duplicates are ignored' do
        it "allows a duplicate record to be saved" do
          expect { described_class.new(duplicate, params, ignore_duplicates: true).save }.
            to change { duplicate.reload.title }.to(params[:title])
        end
      end

      it "checks possible duplication and add to errors, if any found" do
        reference_form = described_class.new(duplicate, params)
        reference_form.save
        expect(reference_form.errors[:possible_duplicate].first).to include "This may be a duplicate of Fisher"
      end
    end
  end

  describe '#collect_errors' do
    let!(:reference) { create :article_reference }
    let(:params) do
      {
        author_names_string: reference.author_names_string,
        journal_name: '',
        pagination: ''
      }
    end

    it 'collects errors from the reference and itself' do
      reference_form = described_class.new(reference, params)

      reference_form.save
      reference_form.collect_errors

      expect(reference_form.errors[:pagination]).to eq ["can't be blank"]
      expect(reference_form.errors[:base]).to eq ["Journal: Name can't be blank"]
    end
  end
end
