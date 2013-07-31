# coding: UTF-8
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
        taxon.should be_kind_of Species
        taxon.name.should_not be_blank
        taxon.protonym.should_not be_blank
        taxon.protonym.name.should_not be_blank
        taxon.protonym.authorship.should_not be_blank
        taxon.type_name.should_not be_blank
      end
      it "should set the parent of a new record" do
        taxon = @mother.create_taxon Rank[:species], @genus
        taxon.parent.should == @genus
      end
    end

    describe "Returning an object web from an existing record" do
      before do
        @genus = create_genus
        @mother = TaxonMother.new @genus.id
      end
      it "should load a record to be edited, filling in child objects" do
        taxon = @mother.load_taxon
        taxon.should == @genus
        taxon.name.should_not be_blank
        taxon.protonym.should_not be_blank
        taxon.protonym.name.should_not be_blank
        taxon.protonym.authorship.should_not be_blank
        taxon.type_name.should_not be_blank
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
      taxon.name.name.should == 'Atta'
      taxon.protonym.name.name.should == 'Betta'
      taxon.type_name.name.should == 'Betta major'
    end

    it "should set the new taxon's state" do
      taxon = @mother.create_taxon Rank[:genus], create_subfamily
      params = @genus_params.deep_dup
      params[:type_fossil] = 0
      params[:type_taxt] = ''
      @mother.save_taxon taxon, params
      taxon.reload

      taxon.should be_waiting
      taxon.can_approve?.should be_true
    end

    it "should create a new species" do
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @species_params.deep_dup
      @mother.save_taxon taxon, params
      taxon.reload
      taxon.name.name.should == 'Atta major'
      taxon.protonym.name.name.should == 'Betta major'
    end

    it "should create a new subspecies" do
      species = create_species
      taxon = @mother.create_taxon Rank[:subspecies], species
      params = @subspecies_params
      @mother.save_taxon taxon, params
      taxon.reload
      taxon.name.name.should == 'Atta major minor'
      taxon.protonym.name.name.should == 'Betta major minor'
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
      taxon.should be_incertae_sedis_in 'genus'
      taxon.should be_nomen_nudum
      taxon.should be_hong
      taxon.should be_unresolved_homonym
      taxon.should be_ichnotaxon
      taxon.headline_notes_taxt.should == "{ref #{headline_reference.id}}"
      taxon.type_taxt.should ==  "{ref #{taxt_reference.id}}"
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
      taxon.protonym.authorship.notes_taxt.should == "{ref #{reference.id}}"
    end

    it "should set homonym replaced by" do
      taxon = @mother.create_taxon Rank[:species], create_genus
      params = @species_params.deep_dup
      replacement_homonym = create_genus
      params[:homonym_replaced_by_name_attributes][:id] = replacement_homonym.name.id

      @mother.save_taxon taxon, params

      taxon.reload

      taxon.homonym_replaced_by.should == replacement_homonym
    end

    describe "Creating a Change" do
      it "should create a Change pointing to the version of Taxon" do
        with_versioning do
          taxon = @mother.create_taxon Rank[:species], create_genus
          @mother.save_taxon taxon, @genus_params
          change = Change.first
          change.paper_trail_version.should == taxon.last_version
        end
      end
    end

  end
end
