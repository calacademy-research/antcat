# coding: UTF-8
require 'spec_helper'

describe Importers::Hol::Catalog do
  describe "Comparing with AntCat" do
    before do
      @hol = Importers::Hol::Catalog.new
    end

    it "should do a merge sort on the two lists" do
      atta = create_genus 'Atta'
      Genus.should_receive(:all).and_return [atta]
      atta.should_receive(:species).and_return ['Atta media', 'Atta minor']
      @hol.should_receive(:species_for_genus).with('Atta').and_return ['Atta albans', 'Atta minor', 'Atta major']
      @hol.compare_with_antcat
      results = HolComparison.order(:name).all.to_a
      results.should have(4).items
      results.map(&:name).should == ['Atta albans', 'Atta major', 'Atta media', 'Atta minor']
      results.map(&:status).should == ['hol', 'hol', 'antcat', 'both']
    end
  end

end
