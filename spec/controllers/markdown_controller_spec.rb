# frozen_string_literal: true

require 'rails_helper'

describe MarkdownController do
  describe "POST preview" do
    let(:text) { "markdown" }

    context 'when not signed in', as: :visitor do
      it 'requires signing in' do
        post :preview, params: { text: text }, format: :json
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when signed in', as: :user do
      it "calls `Markdowns::Render`" do
        expect(Markdowns::Render).to receive(:new).with(text).and_call_original
        post :preview, params: { text: text }
      end

      it 'refuses very long texts' do
        post :preview, params: { text: 'a' * (described_class::MAX_TEXT_LENGTH + 1) }
        expect(response).to have_http_status :content_too_large
      end

      context 'with `format_type_fields`' do
        it "calls `Types::FormatTypeField`" do
          expect(Types::FormatTypeField).to receive(:new).with(text).and_call_original
          post :preview, params: { text: text, format_type_fields: 'true' }
        end
      end
    end
  end
end
