require 'rails_helper'

describe ReferenceForm do
  describe "#save" do
    describe "updating attributes" do
      let!(:reference) { create :unknown_reference }
      let(:params) do
        {
          bolton_key: "Smith, 1858b",
          author_names_string: reference.author_names_string
        }
      end

      specify do
        expect(reference.bolton_key).to eq nil

        described_class.new(reference, params).save

        reference.reload
        expect(reference.bolton_key).to eq params[:bolton_key]
      end
    end

    describe "updating author names" do
      let!(:author_names) { [create(:author_name, name: "Batiatus, B.")] }
      let!(:reference) { create :unknown_reference, author_names: author_names }

      context "when author names have not changed" do
        let(:params) do
          {
            author_names_string: reference.author_names_string
          }
        end

        it "does not create new `AuthorName`s for existing authors" do
          expect { described_class.new(reference, params).save }.
            to_not change { AuthorName.count }
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
              bolton_key: "Smith, 1858b",
              author_names_string: reference.author_names_string
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
              bolton_key: "Smith, 1858b",
              author_names_string: "Batiatus, B.; Glaber, G."
            }
          end

          it "creates a single version for the reference" do
            with_versioning do
              expect { described_class.new(reference, params).save }.
                to change { reference.versions.count }.by(1)
            end
          end

          it "updates `#author_names_string_cache`" do
            expect { described_class.new(reference, params).save }.
              to change { reference.author_names_string_cache }.
              from('Batiatus, B.').to("Batiatus, B.; Glaber, G.")
          end
        end

        context "when more than one author names have been added" do
          let(:params) do
            {
              bolton_key: "Smith, 1858b",
              author_names_string: "Batiatus, B.; Glaber, G.; Borgia, C."
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
              to change { reference.author_names_string_cache }.
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
          let!(:reference) { create :unknown_reference, author_names: author_names }
          let(:params) do
            {
              bolton_key: "Smith, 1858b",
              author_names_string: "Batiatus, B."
            }
          end

          it 'deletes orphaned `ReferenceAuthorName`s' do
            expect(ReferenceAuthorName.count).to eq 2
            expect { described_class.new(reference, params).save }.
              to change { ReferenceAuthorName.count }.by(-1)
          end

          it "updates `#author_names_string_cache`" do
            expect { described_class.new(reference, params).save }.
              to change { reference.author_names_string_cache }.
              from('Batiatus, B.; Glaber, G.').to("Batiatus, B.")
          end
        end
      end
    end

    describe 'reference documents' do
      let(:params) do
        {
          author_names_string: "Batiatus, B.",
          title: "Should be updated",
          document_attributes: {
            url: "http://localhost/documents/#{reference.document.id}/123.pdf",
            id: reference.document.id
          }
        }
      end

      context 'when reference has a document' do
        let!(:reference) { create :unknown_reference, :with_document }

        it 'does not create a new `ReferenceDocument`s' do
          expect(ReferenceDocument.count).to eq 1
          expect { described_class.new(reference, params).save }.
            to change { reference.reload.title }.to(params[:title])
          expect(ReferenceDocument.count).to eq 1
        end
      end
    end

    describe "duplicate checking" do
      let!(:original) { create :article_reference }
      let(:params) do
        {
          author_names_string: original.author_names_string,
          citation_year: original.citation_year,
          title: original.title,
          journal: original.journal,
          series_volume_issue: original.series_volume_issue,
          pagination: original.pagination
        }
      end
      let!(:duplicate) { create :article_reference, author_names: original.author_names }

      it "allows a duplicate record to be saved" do
        expect { described_class.new(duplicate, params, ignore_duplicates: true).save }.not_to raise_error
      end

      it "checks possible duplication and add to errors, if any found" do
        expect(duplicate.errors).to be_empty
        expect(described_class.new(duplicate, params).save).to eq nil
        expect(duplicate.errors[:possible_duplicate].first).to include "This may be a duplicate of Fisher"
      end
    end
  end
end
