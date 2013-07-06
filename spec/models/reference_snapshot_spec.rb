# coding: UTF-8
require 'spec_helper'

#describe ReferenceSnapshot do
  #it "should exist and require the reference version" do
    #snapshot = ReferenceSnapshot.new
    #snapshot.reference.should be_nil
    #snapshot.reference_version.should be_nil
    #snapshot.should_not be_valid

    #snapshot.reference = FactoryGirl.create :article_reference
    #snapshot.should_not be_valid

    #snapshot.reference_version = FactoryGirl.create :version
    #snapshot.should be_valid

    #snapshot.journal_version.should be_nil
    #snapshot.publisher_version.should be_nil
    #snapshot.nested_reference_version.should be_nil
  #end

  #it "should be able to take a snapshot then reify it" do
    #journal = FactoryGirl.create :journal, name: 'Ants'
    #reference = FactoryGirl.create :article_reference, journal: journal

    #ReferenceSnapshot.take_snapshot reference

    #ReferenceSnapshot.should have(1).item
    #snapshot = ReferenceSnapshot.first
  #end

#end
