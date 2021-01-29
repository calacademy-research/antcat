# frozen_string_literal: true

require 'rails_helper'

describe MarkdownController do
  describe "POST preview", as: :visitor do
    let(:text) { "markdown" }

    it "calls `Markdowns::Render`" do
      expect(Markdowns::Render).to receive(:new).with(text).and_call_original
      post :preview, params: { text: text }
    end

    context 'with `format_type_fields`' do
      it "calls `Types::FormatTypeField`" do
        expect(Types::FormatTypeField).to receive(:new).with(text).and_call_original
        post :preview, params: { text: text, format_type_fields: 'true' }
      end
    end
  end
end
