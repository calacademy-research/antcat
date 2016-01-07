require 'spec_helper'
describe TaxonMother do

  describe "Returning a web of objects to be edited in a form" do

    describe "Returning an object web suitable for filling in for a new record" do
      before do
        @genus = create_genus
        @mother = TaxonMother.new
      end
      it "should create a new record to be edited, filling in child objects" do
        taxon = @mother.create_taxon Rank[:species], @genus
        expect(taxon).to be_kind_of Species
        expect(taxon.name).not_to be_blank
        expect(taxon.protonym).not_to be_blank
        expect(taxon.protonym.name).not_to be_blank
        expect(taxon.protonym.authorship).not_to be_blank
        expect(taxon.type_name).not_to be_blank
      end
      it "should set the parent of a new record" do
        taxon = @mother.create_taxon Rank[:species], @genus
        expect(taxon.parent).to eq(@genus)
      end
    end

    describe "Returning an object web from an existing record" do
      before do
        @genus = create_genus
        @mother = TaxonMother.new @genus.id
      end
      it "should load a record to be edited, filling in child objects" do
        taxon = @mother.load_taxon
        expect(taxon).to eq(@genus)
        expect(taxon.name).not_to be_blank
        expect(taxon.protonym).not_to be_blank
        expect(taxon.protonym.name).not_to be_blank
        expect(taxon.protonym.authorship).not_to be_blank
        expect(taxon.type_name).not_to be_blank
      end
    end
  end

  describe "Saving a new record, based on params from a form with nested attributes" do
    before do
      @mother = TaxonMother.new
      @reference = FactoryGirl.create :article_reference
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
      @genus_params[:name_attributes][:id] = FactoryGirl.create(:genus_name, name: 'Atta').id
      @genus_params[:protonym_attributes][:name_attributes][:id] = FactoryGirl.create(:genus_name, name: 'Betta').id
      @genus_params[:type_name_attributes] = {id: FactoryGirl.create(:species_name, name: 'Betta major').id}

      @species_params = @taxon_params.deep_dup
      @species_params[:name_attributes][:id] = FactoryGirl.create(:species_name, name: 'Atta major').id
      @species_params[:protonym_attributes][:name_attributes][:id] = FactoryGirl.create(:species_name, name: 'Betta major').id

      @subspecies_params = @taxon_params.deep_dup
      @subspecies_params[:name_attributes][:id] = FactoryGirl.create(:subspecies_name, name: 'Atta major minor').id
      @subspecies_params[:protonym_attributes][:name_attributes][:id] = FactoryGirl.create(:subspecies_name, name: 'Betta major minor').id
    end

    it "should create a new genus" do
      taxon = @mother.create_taxon Rank[:genus], create_subfamily
      params = @genus_params.deep_dup
      params[:type_fossil] = 0
      params[:type_taxt] = ''
      @mother.save_taxon taxon, params
      taxon.reload
      expect(taxon.name.name).to eq('Atta')
      expect(taxon.protonym.name.name).to eq('Betta')
      expect(taxon.type_name.name).to eq('Betta major')
    end

    it "should set the new taxon's state" do
      taxon = @mother.create_taxon Rank[:genus], create_subfamily
      params = @genus_params.deep_dup
      params[:type_fossil] = 0
      params[:type_taxt] = ''
      @mother.save_taxon taxon, params
      taxon.reload

      expect(taxon).to be_waiting
      expect(taxon.can_approve?).to be_truthy
    end

    it "should create a new species" do
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @species_params.deep_dup
      @mother.save_taxon taxon, params
      taxon.reload
      expect(taxon.name.name).to eq('Atta major')
      expect(taxon.protonym.name.name).to eq('Betta major')
    end

    it "should create a new subspecies" do
      species = create_species
      taxon = @mother.create_taxon Rank[:subspecies], species
      params = @subspecies_params
      @mother.save_taxon taxon, params
      taxon.reload
      expect(taxon.name.name).to eq('Atta major minor')
      expect(taxon.protonym.name.name).to eq('Betta major minor')
    end

    it "should set name, status and flag fields" do
      headline_reference = FactoryGirl.create :article_reference
      taxt_reference = FactoryGirl.create :article_reference
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @taxon_params.deep_dup
      params[:name_attributes][:id] = FactoryGirl.create(:species_name, name: 'Atta major').id
      params[:protonym_attributes][:name_attributes][:id] = FactoryGirl.create(:species_name, name: 'Betta major').id
      params[:incertae_sedis_in] = 'genus'
      params[:nomen_nudum] = '1'
      params[:hong] = '1'
      params[:unresolved_homonym] = '1'
      params[:ichnotaxon] = '1'
      params[:headline_notes_taxt] = Taxt.to_editable "{ref #{headline_reference.id}}"
      params[:type_taxt] = Taxt.to_editable "{ref #{taxt_reference.id}}"

      @mother.save_taxon taxon, params

      taxon.reload
      expect(taxon).to be_incertae_sedis_in 'genus'
      expect(taxon).to be_nomen_nudum
      expect(taxon).to be_hong
      expect(taxon).to be_unresolved_homonym
      expect(taxon).to be_ichnotaxon
      expect(taxon.headline_notes_taxt).to eq("{ref #{headline_reference.id}}")
      expect(taxon.type_taxt).to eq("{ref #{taxt_reference.id}}")
    end

    it "should set authorship taxt" do
      reference = FactoryGirl.create :article_reference
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @taxon_params.deep_dup
      params[:name_attributes][:id] = FactoryGirl.create(:species_name, name: 'Atta major').id
      params[:protonym_attributes][:name_attributes][:id] = FactoryGirl.create(:species_name, name: 'Betta major').id
      params[:protonym_attributes][:authorship_attributes][:notes_taxt] = Taxt.to_editable "{ref #{reference.id}}"

      @mother.save_taxon taxon, params

      taxon.reload
      expect(taxon.protonym.authorship.notes_taxt).to eq("{ref #{reference.id}}")
    end

    it "should set homonym replaced by" do
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @species_params.deep_dup
      replacement_homonym = create_genus
      params[:homonym_replaced_by_name_attributes][:id] = replacement_homonym.name.id

      @mother.save_taxon taxon, params

      taxon.reload

      expect(taxon.homonym_replaced_by).to eq(replacement_homonym)
    end

    it "should set current valid taxon" do
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @species_params.deep_dup
      current_valid_taxon = create_genus
      params[:current_valid_taxon_name_attributes][:id] = current_valid_taxon.name.id

      @mother.save_taxon taxon, params

      taxon.reload

      expect(taxon.current_valid_taxon).to eq(current_valid_taxon)
    end

    it "should allow name gender to be set when updating a taxon" do
      taxon = @mother.create_taxon Rank[:genus], create_subfamily
      params = @genus_params.deep_dup
      @mother.save_taxon taxon, params
      taxon.reload
      expect(taxon.name.gender).to be_nil
      params = @genus_params.deep_dup
      params[:name_attributes][:gender] = 'masculine'
      @mother.save_taxon taxon, params
      taxon.reload
      expect(taxon.name.gender).to eq('masculine')
    end

    it "should allow name gender to be unset when updating a taxon" do
      taxon = @mother.create_taxon Rank[:genus], create_subfamily
      params = @genus_params.deep_dup
      @mother.save_taxon taxon, params
      taxon.name.update_column(:gender, 'masculine')
      expect(taxon.name.gender).to eq('masculine')
      params = @genus_params.deep_dup
      params[:name_attributes][:gender] = ''
      @mother.save_taxon taxon, params
      taxon.reload
      expect(taxon.name.gender).to be_nil
    end

    describe "Creating a Change" do
      it "should create a Change pointing to the version of Taxon when added" do
        with_versioning do
          taxon = @mother.create_taxon Rank[:species], create_genus
          @mother.save_taxon taxon, @genus_params
          change = Change.first
          expect(change.user_changed_taxon_id).to eq(taxon.last_version.item_id)
        end
      end

      it "should create a Change for an edit" do
        genus = create_genus
        with_versioning do
          @mother.save_taxon genus, @genus_params
        end
        expect(Change.count).to equal 1
        expect(Change.first[:change_type]).to eq 'update'
      end
      it "should  change the review state after editing" do
        genus = create_genus
        with_versioning do
          @mother.save_taxon genus, @genus_params
        end
        expect(genus).not_to be_old
      end
    end

  end
end
