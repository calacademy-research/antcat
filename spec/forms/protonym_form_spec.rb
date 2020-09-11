# frozen_string_literal: true

require 'rails_helper'

describe ProtonymForm do
  describe "#save" do
    describe "updating attributes" do
      describe 'updating authorship' do
        let(:protonym) { create :protonym }
        let(:new_reference) { create :any_reference }
        let(:protonym_params) do
          {
            authorship_attributes: {
              pages: '99b',
              reference_id: new_reference.id
            }
          }
        end

        specify do
          expect { described_class.new(protonym, protonym_params).save! }.
            to change { protonym.reload.authorship.reference.id }.to(new_reference.id).
            and change { protonym.authorship.pages }.to('99b')
        end
      end

      describe 'setting a new type name' do
        let(:protonym) { create :protonym }
        let(:type_taxon) { create :genus }
        let(:protonym_params) do
          {
            type_name_attributes: {
              fixation_method: TypeName::BY_MONOTYPY,
              taxon_id: type_taxon.id
            }
          }
        end

        specify do
          expect { described_class.new(protonym, protonym_params).save! }.to change { protonym.reload.type_name }.from(nil)

          type_name = TypeName.last
          expect(type_name.protonym).to eq protonym
          expect(type_name.fixation_method).to eq TypeName::BY_MONOTYPY
          expect(type_name.taxon).to eq type_taxon
        end
      end

      describe "blanking type name's `fixation_method`" do
        let(:type_name) { create :type_name, :by_monotypy }
        let!(:protonym) { create :protonym, type_name: type_name }
        let(:protonym_params) do
          {
            type_name_attributes: {
              fixation_method: ''
            }
          }
        end

        it 'nullifies the `fixation_method`' do
          expect { described_class.new(protonym, protonym_params).save! }.
            to change { type_name.reload.fixation_method }.from(TypeName::BY_MONOTYPY).to(nil)
        end
      end

      describe "blanking type name's `taxon`" do
        let(:type_name) { create :type_name, :by_monotypy }
        let!(:protonym) { create :protonym, type_name: type_name }
        let(:protonym_params) do
          {
            type_name_attributes: {
              taxon_id: ''
            }
          }
        end

        it 'makes validations fail' do
          form = described_class.new(protonym, protonym_params)
          expect(form.save).to eq false
          expect(form.errors[:base]).to include "Type name: Taxon must exist"
        end
      end
    end

    describe "clearing type names" do
      let!(:protonym) { create :protonym, :with_type_name }
      let(:form_params) do
        {
          destroy_type_name: '1'
        }
      end

      it "nilifies the promtonym's type name" do
        expect { described_class.new(protonym, {}, form_params).save! }.to change { protonym.reload.type_name }.to(nil)
      end

      it 'destroys the `TypeName` record' do
        expect { described_class.new(protonym, {}, form_params).save! }.to change { TypeName.count }.by(-1)
      end
    end

    describe "promoting errors" do
      let!(:protonym) { Protonym.new }
      let(:protonym_params) do
        {}
      end

      before do
        protonym.build_name
        protonym.build_authorship
        protonym.build_type_name
      end

      it "collects validation errors" do
        form = described_class.new(protonym, protonym_params)

        expect { form.save }.to_not change { Protonym.count }

        expect(form.errors[:base]).to include "Name can't be blank"
        expect(form.errors[:base]).to include "Authorship: Reference must exist"
        expect(form.errors[:base]).to include "Authorship: Pages can't be blank"
        expect(form.errors[:base]).to include "Type name: Taxon must exist"
      end
    end
  end
end
