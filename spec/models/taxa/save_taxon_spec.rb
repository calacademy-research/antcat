require 'spec_helper'

# Extra madness because RSpec had problems finding our classes
Taxa::Family = Family

describe Taxa::SaveTaxon do

  describe "Saving a new record, based on params from a form with nested attributes" do
    before do
      @reference = create :article_reference
      @taxon_params = HashWithIndifferentAccess.new(
        name_attributes:     {id: ''},
        status:              'valid',
        incertae_sedis_in:   '',
        fossil:              '0',
        nomen_nudum:         '0',
        current_valid_taxon_name_attributes: {id: ''},
        unresolved_homonym:  '0',
        ichnotaxon:          '0',
        hong:                '0',
        headline_notes_taxt: '',
        homonym_replaced_by_name_attributes: {id: ''},
        protonym_attributes: {
          name_attributes:  {id: ''},
          fossil:           '0',
          sic:              '0',
          locality:         '',
          authorship_attributes: {
            reference_attributes: {id: @reference.id},
            pages: '',
            forms: '',
            notes_taxt: '',
          },
        }
      )
      @genus_params = @taxon_params.deep_dup
      @genus_params[:name_attributes][:id] = create(:genus_name, name: 'Atta').id
      @genus_params[:protonym_attributes][:name_attributes][:id] = create(:genus_name, name: 'Betta').id
      @genus_params[:type_name_attributes] = {id: create(:species_name, name: 'Betta major').id}

      @species_params = @taxon_params.deep_dup
      @species_params[:name_attributes][:id] = create(:species_name, name: 'Atta major').id
      @species_params[:protonym_attributes][:name_attributes][:id] = create(:species_name, name: 'Betta major').id

      @subspecies_params = @taxon_params.deep_dup
      @subspecies_params[:name_attributes][:id] = create(:subspecies_name, name: 'Atta major minor').id
      @subspecies_params[:protonym_attributes][:name_attributes][:id] = create(:subspecies_name, name: 'Betta major minor').id
    end

    it "saves a new genus" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = @genus_params.deep_dup
      params[:type_fossil] = 0
      params[:type_taxt] = ''
      taxon.save_taxon params
      taxon.reload
      expect(taxon.name.name).to eq('Atta')
      expect(taxon.protonym.name.name).to eq('Betta')
      expect(taxon.type_name.name).to eq('Betta major')
    end

    it "sets the new taxon's state" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = @genus_params.deep_dup
      params[:type_fossil] = 0
      params[:type_taxt] = ''
      taxon.save_taxon params
      taxon.reload

      expect(taxon).to be_waiting
      expect(taxon.can_approve?).to be_truthy
    end

    it "saves a new species" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = @species_params.deep_dup
      taxon.save_taxon params
      taxon.reload
      expect(taxon.name.name).to eq('Atta major')
      expect(taxon.protonym.name.name).to eq('Betta major')
    end

    it "saves a new subspecies" do
      taxon = build_new_taxon_and_set_parent :subspecies, create_species
      params = @subspecies_params
      taxon.save_taxon params
      taxon.reload
      expect(taxon.name.name).to eq('Atta major minor')
      expect(taxon.protonym.name.name).to eq('Betta major minor')
    end

    it "sets name, status and flag fields" do
      headline_reference = create :article_reference
      taxt_reference = create :article_reference
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = @taxon_params.deep_dup
      params[:name_attributes][:id] = create(:species_name, name: 'Atta major').id
      params[:protonym_attributes][:name_attributes][:id] = create(:species_name, name: 'Betta major').id
      params[:incertae_sedis_in] = 'genus'
      params[:nomen_nudum] = '1'
      params[:hong] = '1'
      params[:unresolved_homonym] = '1'
      params[:ichnotaxon] = '1'
      params[:headline_notes_taxt] = Taxt.to_editable "{ref #{headline_reference.id}}"
      params[:type_taxt] = Taxt.to_editable "{ref #{taxt_reference.id}}"

      taxon.save_taxon params

      taxon.reload
      expect(taxon).to be_incertae_sedis_in 'genus'
      expect(taxon).to be_nomen_nudum
      expect(taxon).to be_hong
      expect(taxon).to be_unresolved_homonym
      expect(taxon).to be_ichnotaxon
      expect(taxon.headline_notes_taxt).to eq("{ref #{headline_reference.id}}")
      expect(taxon.type_taxt).to eq("{ref #{taxt_reference.id}}")
    end

    it "sets authorship taxt" do
      reference = create :article_reference
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = @taxon_params.deep_dup
      params[:name_attributes][:id] = create(:species_name, name: 'Atta major').id
      params[:protonym_attributes][:name_attributes][:id] = create(:species_name, name: 'Betta major').id
      params[:protonym_attributes][:authorship_attributes][:notes_taxt] = Taxt.to_editable "{ref #{reference.id}}"

      taxon.save_taxon params

      taxon.reload
      expect(taxon.protonym.authorship.notes_taxt).to eq("{ref #{reference.id}}")
    end

    it "sets homonym replaced by" do
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = @species_params.deep_dup
      replacement_homonym = create_genus
      params[:homonym_replaced_by_name_attributes][:id] = replacement_homonym.name.id

      taxon.save_taxon params

      taxon.reload

      expect(taxon.homonym_replaced_by).to eq(replacement_homonym)
    end

    it "sets current valid taxon" do
      taxon = build_new_taxon_and_set_parent :species, create_genus
      params = @species_params.deep_dup
      current_valid_taxon = create_genus
      params[:current_valid_taxon_name_attributes][:id] = current_valid_taxon.name.id

      taxon.save_taxon params
      taxon.reload
      expect(taxon.current_valid_taxon).to eq(current_valid_taxon)
    end

    it "allows name gender to be set when updating a taxon" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = @genus_params.deep_dup
      taxon.save_taxon params
      taxon.reload
      expect(taxon.name.gender).to be_nil
      params = @genus_params.deep_dup
      params[:name_attributes][:gender] = 'masculine'
      taxon.save_taxon params
      taxon.reload
      expect(taxon.name.gender).to eq('masculine')
    end

    it "allows name gender to be unset when updating a taxon" do
      taxon = build_new_taxon_and_set_parent :genus, create_subfamily
      params = @genus_params.deep_dup
      taxon.save_taxon params
      taxon.name.update_column(:gender, 'masculine')
      expect(taxon.name.gender).to eq('masculine')
      params = @genus_params.deep_dup
      params[:name_attributes][:gender] = ''
      taxon.save_taxon params
      taxon.reload
      expect(taxon.name.gender).to be_nil
    end

    describe "Creating a Change" do
      it "creates a Change pointing to the version of Taxon when added" do
        with_versioning do
          taxon = build_new_taxon_and_set_parent :species, create_genus
          taxon.save_taxon @genus_params
          change = Change.first
          expect(change.user_changed_taxon_id).to eq(taxon.last_version.item_id)
        end
      end

      it "creates a Change for an edit" do
        genus = create_genus
        with_versioning do
          genus.save_taxon @genus_params
        end
        expect(Change.count).to equal 1
        expect(Change.first[:change_type]).to eq 'update'
      end
      it "changes the review state after editing" do
        genus = create_genus
        with_versioning do
          genus.save_taxon @genus_params
        end
        expect(genus).not_to be_old
      end
    end

  end
end

# custom method to avoid interference from the factories
def build_new_taxon_and_set_parent rank, parent
  taxon = "#{rank}".titlecase.constantize.new
  taxon.build_name
  taxon.build_type_name
  taxon.build_protonym
  taxon.protonym.build_name
  taxon.protonym.build_authorship
  taxon.parent = parent
  taxon
end
