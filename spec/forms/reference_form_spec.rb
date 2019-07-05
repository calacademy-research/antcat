require 'spec_helper'

describe ReferenceForm do
  describe "#save" do
    let(:original_params) { {} }
    let(:request_host) { 123 }

    context "when reference exists" do
      describe "updating attributes" do
        let!(:reference) { create :unknown_reference }
        let(:reference_params) do
          {
            bolton_key: "Smith, 1858b",
            author_names_string: reference.author_names_string
          }
        end

        specify do
          expect(reference.bolton_key).to be nil

          described_class.new(reference, reference_params, original_params, request_host).save

          reference.reload
          expect(reference.bolton_key).to eq reference_params[:bolton_key]
        end
      end

      describe "updating attributes" do
        let!(:author_names) { [create(:author_name, name: "Batiatus, B.")] }
        let!(:reference) { create :unknown_reference, author_names: author_names }

        context "when author names have not changed" do
          let(:reference_params) do
            {
              author_names_string: reference.author_names_string
            }
          end

          it "does not create new `AuthorName`s for existing authors" do
            expect { described_class.new(reference, reference_params, original_params, request_host).save }.
              to_not change { AuthorName.count }
          end

          it "does not create any version for the referene" do
            with_versioning do
              expect { described_class.new(reference, reference_params, original_params, request_host).save }.
                to_not change { reference.versions.count }
            end
          end
        end

        context "when something has changed" do
          context "when author names have not changed" do
            let(:reference_params) do
              {
                bolton_key: "Smith, 1858b",
                author_names_string: reference.author_names_string
              }
            end

            it "creates a single version for the reference" do
              with_versioning do
                expect { described_class.new(reference, reference_params, original_params, request_host).save }.
                  to change { reference.versions.count }.by(1)
              end
            end
          end

          context "when an author names have been added" do
            let(:reference_params) do
              {
                bolton_key: "Smith, 1858b",
                author_names_string: "Batiatus, B.; Glaber, G."
              }
            end

            # TODO: We may want this.
            xit "creates a single version for the reference" do
              with_versioning do
                expect { described_class.new(reference, reference_params, original_params, request_host).save }.
                  to change { reference.versions.count }.by(1)
              end
            end

            it "updates `#author_names_string_cache`" do
              with_versioning do
                expect { described_class.new(reference, reference_params, original_params, request_host).save }.
                  to change { reference.author_names_string_cache }.to("Batiatus, B.; Glaber, G.")
              end
            end
          end
        end
      end
    end

    describe "duplicate checking" do
      let!(:original) { create :article_reference }
      let(:reference_params) do
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
        expect { described_class.new(duplicate, reference_params, original_params, request_host).save }.not_to raise_error
      end

      it "checks possible duplication and add to errors, if any found" do
        expect(duplicate.errors).to be_empty
        expect(described_class.new(duplicate, reference_params, original_params, request_host).save).to be nil
        expect(duplicate.errors[:base].first).to include "This may be a duplicate of Fisher"
      end
    end
  end
end
