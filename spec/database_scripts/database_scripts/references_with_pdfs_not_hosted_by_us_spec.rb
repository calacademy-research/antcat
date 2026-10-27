# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ReferencesWithPdfsNotHostedByUs do
  let(:script) { described_class.new }

  context "with results" do
    let!(:document) { create :reference_document, :with_reference, file_file_name: '1.pdf' }

    context "when the URL is a plain web link" do
      before do
        document.update_columns(url: 'https://example.com/paper.pdf')
      end

      it "links it" do
        rendered = DatabaseScripts::Render.new(script, {}).call
        expect(rendered).to include 'href="https://example.com/paper.pdf"'
      end
    end

    context "when the URL is not a web link (legacy data)" do
      before do
        document.update_columns(url: 'javascript:alert(1)')
      end

      it "shows it as text, not as a link" do
        rendered = DatabaseScripts::Render.new(script, {}).call
        expect(rendered).to include 'javascript:alert(1)'
        expect(rendered).not_to include 'href="javascript'
      end
    end
  end
end
