require 'spec_helper'

describe ReferenceForm do
  describe "#save" do
    context "when reference exists" do
      let(:reference) { create :unknown_reference }
      let(:reference_params) do
        {
          bolton_key: "Smith, 1858b",
          author_names_string: "Smith, F."
        }
      end
      let(:original_params) { {} }
      let(:request_host) { 123 }

      specify do
        expect(reference.bolton_key).to be nil

        described_class.new(reference, reference_params, original_params, request_host).save

        reference.reload
        expect(reference.bolton_key).to eq reference_params[:bolton_key]
      end
    end
  end
end
