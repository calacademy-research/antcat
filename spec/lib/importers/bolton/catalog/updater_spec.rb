# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Updater do
  before do
    reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1913a'
    @data = {
      tribe_name: 'Attini',
      protonym: {tribe_name: 'Attini',
                 authorship: [{author_names: ['Emery'], year: '1913a', pages: '6'}]},
      type_genus: {genus_name: 'Atta'},
      history: ['Attini history'],
    }
    @attini = Tribe.import @data
    @ecitonini = create_tribe 'Ecitonini'
    @bacerosini = create_tribe 'Baserosini'
    @formicini = create_tribe 'Formicini'
  end

  describe "Updating synonyms" do
    it "should handle the addition of a synonym" do
      @data[:status] = 'synonym'
      @data[:synonym_of] = @bacerosini
      Tribe.import @data
      @attini.reload.should be_junior_synonym_of @bacerosini

      Update.count.should == 2

      update = Update.find_by_record_id_and_field_name @attini.id, :junior_synonym_of
      update.class_name.should == 'Tribe'
      update.before.should == nil
      update.after.should == 'Baserosini'

      update = Update.find_by_record_id_and_field_name @attini.id, :status
      update.class_name.should == 'Tribe'
      update.before.should == 'valid'
      update.after.should == 'synonym'
    end
  end

end
