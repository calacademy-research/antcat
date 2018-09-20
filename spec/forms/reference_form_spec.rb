require 'spec_helper'

describe ReferenceForm do
  describe "#save" do
    context "when reference exists" do
      let(:original_params) { {} }
      let(:request_host) { 123 }

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
        let!(:author_names) do
          [
            create(:author_name, name: "Fisher, B."),
            create(:author_name, name: "Bolton, B."),
            create(:author_name, name: "Batiatus, B.")
          ]
        end
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
      end
    end
  end
end
