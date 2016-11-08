require 'spec_helper'

describe "MissingReferenceDecorator formerly MissingReferenceKey" do
  let(:reference) { build_stubbed :missing_reference, citation: "citation" }

  describe "Unapplicable methods" do
    it "just returns nil from them" do
      expect(reference.decorate.format_reference_document_link).to be_nil
      expect(reference.decorate.goto_reference_link).to be_nil
    end
  end
end
