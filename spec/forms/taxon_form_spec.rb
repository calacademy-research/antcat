require 'spec_helper'

# HACK: extra madness because RSpec had problems finding our classes.
Taxa::Family = Family

describe TaxonForm do
  include RefactorTaxonFactoriesHelpers

  describe "Saving a new record, based on params from a form with nested attributes" do
    it "saves a new genus" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = genus_params

      params[:type_fossil] = 0
      params[:type_taxt] = ''

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.name.name).to eq 'Atta'
      expect(taxon.protonym.name.name).to eq 'Betta'
      expect(taxon.type_name.name).to eq 'Betta major'
    end

    it "saves a new subgenus" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = subgenus_params

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.name.name).to eq 'Atta (Attacus)'
      expect(taxon.protonym.name.name).to eq 'Attacus'
    end

    it "sets the new taxon's state" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = genus_params

      params[:type_fossil] = 0
      params[:type_taxt] = ''

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon).to be_waiting
      expect(taxon.can_approve?).to be_truthy
    end

    it "saves a new species" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = species_params

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.name.name).to eq 'Atta major'
      expect(taxon.protonym.name.name).to eq 'Betta major'
    end

    it "saves a new subspecies" do
      taxon = build_new_taxon_and_set_parent :subspecies, create_species
      params = subspecies_params

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.name.name).to eq 'Atta major minor'
      expect(taxon.protonym.name.name).to eq 'Betta major minor'
    end

    it "sets name, status and flag fields" do
      headline_reference = create :article_reference
      taxt_reference = create :article_reference
      taxon = build_new_taxon_and_set_parent :species, create_genus

      params = taxon_params
      params[:name_attributes][:id] = create(:species_name, name: 'Atta major').id
      params[:protonym_attributes][:name_attributes][:id] = create(:species_name, name: 'Betta major').id
      params[:incertae_sedis_in] = 'genus'
      params[:nomen_nudum] = '1'
      params[:hong] = '1'
      params[:unresolved_homonym] = '1'
      params[:ichnotaxon] = '1'
      params[:headline_notes_taxt] = "{ref #{headline_reference.id}}"
      params[:type_taxt] = "{ref #{taxt_reference.id}}"

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.incertae_sedis_in).to eq 'genus'
      expect(taxon).to be_nomen_nudum
      expect(taxon).to be_hong
      expect(taxon).to be_unresolved_homonym
      expect(taxon).to be_ichnotaxon
      expect(taxon.headline_notes_taxt).to eq "{ref #{headline_reference.id}}"
      expect(taxon.type_taxt).to eq "{ref #{taxt_reference.id}}"
    end

    it "sets authorship taxt" do
      reference = create :article_reference
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = taxon_params

      params[:name_attributes][:id] = create(:species_name, name: 'Atta major').id
      params[:protonym_attributes][:name_attributes][:id] =
        create(:species_name, name: 'Betta major').id
      params[:protonym_attributes][:authorship_attributes][:notes_taxt] = "{ref #{reference.id}}"

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.protonym.authorship.notes_taxt).to eq "{ref #{reference.id}}"
    end

    it "sets homonym replaced by" do
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = species_params
      replacement_homonym = create_genus

      params[:homonym_replaced_by_id] = replacement_homonym.id

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.homonym_replaced_by).to eq replacement_homonym
    end

    it "sets current valid taxon" do
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = species_params
      current_valid_taxon = create_genus

      params[:current_valid_taxon_id] = current_valid_taxon.id
      params[:status] = Status::UNAVAILABLE

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.current_valid_taxon).to eq current_valid_taxon
    end

    it "allows name gender to be set when updating a taxon" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily

      # Must do this, probably so that a new genus isn't created.
      @genus_params = genus_params.deep_dup
      params_without_gender = @genus_params.deep_dup

      described_class.new(taxon, params_without_gender).save

      taxon.reload
      expect(taxon.name.gender).to be_nil

      params_with_gender = @genus_params.deep_dup
      params_with_gender[:name_attributes][:gender] = 'masculine'

      described_class.new(taxon, params_with_gender).save

      taxon.reload
      expect(taxon.name.gender).to eq 'masculine'
    end

    it "allows name gender to be unset when updating a taxon" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = genus_params

      described_class.new(taxon, params).save

      taxon.name.update_column :gender, 'masculine'
      expect(taxon.name.gender).to eq 'masculine'

      params = genus_params
      params[:name_attributes][:gender] = ''

      described_class.new(taxon, params).save

      taxon.reload
      expect(taxon.name.gender).to be_nil
    end

    describe "Creating a Change" do
      context "when a taxon is added" do
        let!(:taxon) { build_new_taxon_and_set_parent :species, create_genus }

        it "creates a Change pointing to the version of Taxon" do
          expect do
            with_versioning { described_class.new(taxon, genus_params).save }
          end.to change { Change.count }.from(0).to(1)
          expect(Change.first.taxon_id).to eq taxon.versions.reload.last.item_id
        end
      end

      context "when a taxon is edited" do
        let(:genus) { create_genus }

        it "creates a Change for an edit" do
          expect do
            with_versioning { described_class.new(genus, genus_params).save }
          end.to change { Change.count }.from(0).to(1)
          expect(Change.first.change_type).to eq 'update'
        end

        it "changes the review state" do
          genus.taxon_state.update_columns review_state: TaxonState::OLD
          genus.reload

          expect do
            with_versioning { described_class.new(genus, genus_params).save }
          end.to change { genus.old? }.from(true).to(false)
        end
      end
    end
  end

  # Mainly tested in `callbacks_and_validations_spec.rb`.
  describe "stuff from Taxa::CallbacksAndValidations" do
    describe "Taxon#save_children" do
      let!(:species) { create :species }
      let!(:genus) { Taxon.find species.genus.id }
      let!(:tribe) { Taxon.find genus.tribe.id }
      let!(:subfamily) { Taxon.find species.subfamily.id }

      context "when taxon is the `save_initiator`" do
        it "saves the children" do
          # Save these:
          expect_any_instance_of(Genus).to receive(:save!).and_call_original
          expect_any_instance_of(Genus).to receive(:save_children).and_call_original

          expect_any_instance_of(Species).to receive(:save).and_call_original
          expect_any_instance_of(Species).to receive(:save_children).and_call_original

          # Should not be saved:
          [Family, Subfamily, Tribe].each do |klass|
            expect_any_instance_of(klass).not_to receive(:save_children).and_call_original
            expect_any_instance_of(klass).not_to receive(:save).and_call_original
          end

          described_class.new(genus, genus_params).save
        end
      end
    end

    describe "Taxon#remove_auto_generated" do
      include MarkAsAutogeneratedHelpers

      let!(:genus) { create_genus }
      let!(:another_genus) { create_genus }
      let!(:synonym) { create :synonym, senior_synonym: genus, junior_synonym: another_genus }
      let!(:actors) { [genus, genus.name, synonym] }

      before { mark_as_auto_generated actors }

      it "removes 'auto_generated' flags from things" do
        described_class.new(genus, genus_params).save

        actors.each &:reload

        expect(genus).not_to be_auto_generated
        expect(synonym).not_to be_auto_generated
        expect(genus.name).not_to be_auto_generated
      end
    end

    context "#set_taxon_state_to_waiting" do
      let(:genus) { create_genus }

      before do
        genus.taxon_state.update_columns review_state: TaxonState::OLD
        genus.reload
        expect(genus).to be_old
      end

      it "changes the review state" do
        with_versioning { described_class.new(genus, genus_params).save }
        expect(genus).not_to be_old
      end
    end
  end
end

def taxon_params
  reference = create :article_reference
  HashWithIndifferentAccess.new(
    name_attributes:     { id: '' },
    status:              Status::VALID,
    incertae_sedis_in:   '',
    fossil:              '0',
    nomen_nudum:         '0',
    current_valid_taxon_id: '',
    unresolved_homonym:  '0',
    ichnotaxon:          '0',
    hong:                '0',
    headline_notes_taxt: '',
    homonym_replaced_by_id: '',
    protonym_attributes: {
      name_attributes:  { id: '' },
      fossil:           '0',
      sic:              '0',
      locality:         '',
      authorship_attributes: {
        reference_id: reference.id,
        pages: '',
        forms: '',
        notes_taxt: ''
      }
    }
  ).deep_dup
end

def genus_params
  params = taxon_params
  params[:name_attributes][:id] = create(:genus_name, name: 'Atta').id
  params[:protonym_attributes][:name_attributes][:id] = create(:genus_name, name: 'Betta').id
  params[:type_name_attributes] = { id: create(:species_name, name: 'Betta major').id }
  params.deep_dup
end

def subgenus_params
  params = taxon_params
  params[:name_attributes][:id] = create(:subgenus_name, name: 'Atta (Attacus)').id
  params[:protonym_attributes][:name_attributes][:id] = create(:genus_name, name: 'Attacus').id
  params[:type_name_attributes] = { id: create(:species_name, name: 'Atta major').id }
  params.deep_dup
end

def species_params
  params = taxon_params
  params[:name_attributes][:id] = create(:species_name, name: 'Atta major').id
  params[:protonym_attributes][:name_attributes][:id] = create(:species_name, name: 'Betta major').id
  params.deep_dup
end

def subspecies_params
  params = taxon_params
  params[:name_attributes][:id] = create(:subspecies_name, name: 'Atta major minor').id
  params[:protonym_attributes][:name_attributes][:id] = create(:subspecies_name, name: 'Betta major minor').id
  params.deep_dup
end
