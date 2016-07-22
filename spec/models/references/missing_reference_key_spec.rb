require 'spec_helper'

describe "MissingReferenceDecorator formerly MissingReferenceKey" do

  describe "Link" do
    it "should simply output its citation" do
      reference = create :missing_reference, citation: "citation"
      expect(reference.decorate.to_link).to eq 'citation'
    end
  end

  describe "Unapplicable methods" do
    it "should just return nil from them" do
      reference = create :missing_reference, citation: "citation"
      expect(reference.decorate.format_reference_document_link).to be_nil
      expect(reference.decorate.goto_reference_link).to be_nil
    end
  end

end
