# coding: UTF-8
require 'spec_helper'

describe Status do

  describe "Status labels" do
    it "should return the singular and the plural for a status" do
      Status['synonym'].to_s.should == 'synonym'
      Status['synonym'].to_s(:plural).should == 'synonyms'
    end
  end

end
