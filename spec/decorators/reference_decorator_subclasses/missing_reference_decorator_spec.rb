# frozen_string_literal: true

require 'rails_helper'

describe MissingReferenceDecorator do
  describe "#format_document_links" do
    let(:reference) { build_stubbed :missing_reference, citation: "citation" }

    specify { expect(reference.decorate.format_document_links).to eq nil }
  end
end
