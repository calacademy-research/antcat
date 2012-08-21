# coding: UTF-8
require 'spec_helper'

describe ForwardRefFromTaxt do

  it "needs a name" do
    ForwardRefFromTaxt.new.should_not be_valid
    ForwardRefFromTaxt.new(name: create_name('Atta')).should be_valid
  end

  it "should change the taxt in the source to a {tax xxxx} tag" do
    genus = create_genus 'Atta'
    item = FactoryGirl.create :taxonomic_history_item, taxt: "{nam #{genus.name.id}}"
    forward_ref = ForwardRefFromTaxt.create! fixee: item, fixee_attribute: :taxt, name: genus.name
    forward_ref.fixup
    item.reload.taxt.should == "{tax #{genus.id}}"
  end

end
