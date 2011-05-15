require 'spec_helper'

describe TaxonomicHistoryHelper do

  it "should merely delegate to the formatter" do
    CatalogFormatter.should_receive(:format_taxonomic_history).with(:foo).and_return :bar
    helper.taxonomic_history(:foo).should == :bar
  end

end

