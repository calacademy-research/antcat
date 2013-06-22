# coding: UTF-8
require 'spec_helper'

class UpdaterTest
  include Importers::Bolton::Catalog::Updater
end

describe Importers::Bolton::Catalog::Updater do
  describe "Doing something that requires this before" do
    before do
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1913a'
      subfamily = create_subfamily
      @data = {
        tribe_name: 'Attini',
        protonym: {tribe_name: 'Attini',
                  authorship: [{author_names: ['Emery'], year: '1913a', pages: '6'}]},
        type_genus: {genus_name: 'Atta'},
        history: ['Attini history'],
        subfamily: subfamily
      }
      # create the tribe from scratch
      @attini = Tribe.import @data
      Update.count.should == 1
      @ecitonini = create_tribe 'Ecitonini'
      @bacerosini = create_tribe 'Baserosini'
      @formicini = create_tribe 'Formicini'
    end

    describe "Updating synonyms" do
      it "should handle the addition of a synonym" do
        @data[:status] = 'synonym'
        @data[:synonym_of] = @bacerosini
        # update the existing tribe
        Tribe.import @data
        @attini.should be_junior_synonym_of @bacerosini
        @bacerosini.should be_senior_synonym_of @attini

        Update.count.should == 3

        update = Update.find_by_record_id_and_field_name @attini.id, 'status'
        update.class_name.should == 'Tribe'
        update.before.should == 'valid'
        update.after.should == 'synonym'

        update = Update.find_by_record_id_and_field_name @attini.id, 'junior_synonym_of'
        update.class_name.should == 'Tribe'
        update.before.should == nil
        update.after.should == 'Baserosini'
      end

      describe "Unit test" do
        it "should record when a junior synonymy is removed" do
          @attini.become_junior_synonym_of @bacerosini
          @attini.update_synonyms do
            @attini.become_not_junior_synonym_of @bacerosini
          end
          Update.count.should == 2
          update = Update.find_by_record_id_and_field_name @attini.id, 'junior_synonym_of'
          update.before.should == 'Baserosini'
          update.after.should == nil
        end

        it "should record when a junior synonymy is added" do
          @attini.update_synonyms do
            @attini.become_junior_synonym_of @bacerosini
          end
          Update.count.should == 2
          update = Update.find_by_record_id_and_field_name @attini.id, 'junior_synonym_of'
          update.before.should == nil
          update.after.should == 'Baserosini'
        end

        it "should record when a senior synonymy is removed" do
          @bacerosini.become_junior_synonym_of @attini
          @attini.update_synonyms do
            @bacerosini.become_not_junior_synonym_of @attini
          end
          Update.count.should == 2
          update = Update.find_by_record_id_and_field_name @attini.id, 'senior_synonym_of'
          update.before.should == 'Baserosini'
          update.after.should == nil
        end

        it "should record when a senior synonymy is added" do
          @attini.update_synonyms do
            @bacerosini.become_junior_synonym_of @attini
          end
          Update.count.should == 2
          update = Update.find_by_record_id_and_field_name @attini.id, 'senior_synonym_of'
          update.before.should == nil
          update.after.should == 'Baserosini'
        end

      end
    end
  end

  describe "Looking up to see if a taxon already exists" do
    it "should look in the nester, if can't find the year in nestee" do
      nestee = FactoryGirl.create :reference, year: '2006', author_names: [FactoryGirl.create(:author_name, name: 'Swainson')], pages_in: 'Pp 2 in:', bolton_key_cache: 'Swainson 1840'
      reference = NestedReference.create! title: 'Ants', citation_year: '1840', author_names: [FactoryGirl.create(:author_name, name: 'Shuckard')], nested_reference: nestee, bolton_key_cache: 'Swainson Shuckard 1840', pages_in: '22'
      authorship = FactoryGirl.create :citation, reference: reference
      protonym = FactoryGirl.create :protonym, authorship: authorship
      genus = create_genus 'Atta', protonym: protonym

      data = {genus_name: 'Atta',
              protonym: {genus_name: 'Formicina', authorship:
                [{author_names: ['Shuckard'],
                  in: {author_names: ['Swainson', 'Shuckard'], year: '1840'},
                  pages: '172'}]},
      }

      taxon, name = Genus.find_taxon_to_update(data)
      taxon.should == genus
    end
  end

end
