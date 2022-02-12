# frozen_string_literal: true

require 'rails_helper'

describe References::ExportsController do
  describe "GET endnote", as: :visitor do
    describe "with `id` in params" do
      let!(:reference) { create :any_reference }

      before do
        create :any_reference # Unrelated.
      end

      it "exports the reference" do
        get :endnote, params: { id: reference.id }
        expect(response.body).to eq Exporters::Endnote::Formatter[[reference]]
      end
    end

    describe "with `reference_q` in params", :search do
      let!(:reference_1) { create :any_reference, title: 'pizza' }
      let!(:reference_2) { create :any_reference, title: 'more pizza' }

      before do
        create :any_reference # Unrelated.
        Sunspot.commit
      end

      it "exports the references" do
        get :endnote, params: { reference_q: "pizza" }
        expect(response.body).to eq Exporters::Endnote::Formatter[[reference_1, reference_2]]
      end
    end
  end

  describe "GET wikipedia", as: :visitor do
    describe "with `id` in params" do
      let!(:reference) { create :any_reference }

      before do
        create :any_reference # Unrelated.
      end

      it "exports the reference" do
        get :wikipedia, params: { id: reference.id }
        expect(response.body).to eq Wikipedia::ReferenceExporter[reference]
      end
    end
  end
end
