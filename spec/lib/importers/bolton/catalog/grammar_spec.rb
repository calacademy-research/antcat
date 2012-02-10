# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Grammar do

  it "should recognize incertae sedis" do
    Bolton::Catalog::Grammar.parse('<i>incertae sedis</i> in ', :root => :incertae_sedis_in).should_not be_nil
  end

  it "should recognize incertae sedis when " do
    Bolton::Catalog::Grammar.parse('<i>incertae sedis </i>in ', :root => :incertae_sedis_in).should_not be_nil
  end

  it "should recognize incertae sedis when " do
    Bolton::Catalog::Grammar.parse("<i> incertae sedis</i> in ", :root => :incertae_sedis_in).should_not be_nil
  end

end
