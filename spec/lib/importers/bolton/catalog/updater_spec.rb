# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Updater do
  before do
    @atta = create_genus 'Atta'
    @eciton = create_genus 'Eciton'
    @baceros = create_genus 'Baseros'
    Synonym.create! junior_synonym: @atta, senior_synonym: @baceros
  end

  describe "Updating synonyms" do
    it "should handle the removal of a synonym" do
      @atta.update_synonyms do

      end
    end
    #it "should handle the addition of a synonym"
  end

end
