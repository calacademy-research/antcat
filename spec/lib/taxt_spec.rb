# coding: UTF-8
require 'spec_helper'

describe Taxt do

  describe "Encodings" do
    it "should encode an unparseable string" do
      Taxt.encode_unparseable('foo').should == '{? foo}'
    end
    it "should encode a reference" do
      reference = FactoryGirl.create :book_reference
      Taxt.encode_reference(reference).should == "{ref #{reference.id}}"
    end
    it "should put italics back around taxon names" do
      Taxt.encode_taxon_name('Atta', :genus).should == "<i>Atta</i>"
    end
    it "should handle a species name" do
      Taxt.encode_taxon_name('Eoformica', :genus, species_epithet: 'eofornica').should == "<i>Eoformica eofornica</i>"
    end
    it "should handle a species name with subgenus" do
      Taxt.encode_taxon_name("Formica", :genus, subgenus_epithet:"Hypochira", species_epithet:"subspinosa").should == "<i>Formica (Hypochira) subspinosa</i>"
    end
    it "should handle a genus abbreviation + subgenus epithet" do
      Taxt.encode_taxon_name('', nil, genus_abbreviation: 'C.', subgenus_epithet:"Hypochira").should == "<i>C. (Hypochira)</i>"
    end
    it "should handle a genus name + subgenus epithet" do
      Taxt.encode_taxon_name('Acanthostichus', :genus, subgenus_epithet:"Ctenopyga").should == "<i>Acanthostichus (Ctenopyga)</i>"
    end
    it "should handle a genus abbreviation + species epithet" do
      Taxt.encode_taxon_name('', nil, genus_abbreviation: 'C.', species_epithet:"major").should == "<i>C. major</i>"
    end
    it "should handle a lone species epithet" do
      Taxt.encode_taxon_name('brunneus', :species_group_epithet, species_group_epithet: 'brunneus').should == "<i>brunneus</i>"
    end
    it "should put a question mark after questionable names" do
      Taxt.encode_taxon_name('Atta', :genus, :questionable => true).should == "<i>Atta?</i>"
    end
    it "should put a dagger in front" do
      Taxt.encode_taxon_name('Atta', :genus, :fossil => true).should == "<i>&dagger;Atta</i>"
    end
    it "should not freak at a family_or_subfamily" do
      Taxt.encode_taxon_name('Dolichoderinae', :family_or_subfamily).should == "Dolichoderinae"
    end

    describe "Genus name" do
      it "should create a ForwardRef from the item to the genus" do
        taxt = Taxt.encode_taxon_name 'Atta', :genus_name
        forward_ref_id = taxt.match(/^{tax (\d+)}$/)[1]
        forward_ref_id.should_not be_blank
        forward_ref.name.to_s.should == 'Atta'
        forward_ref.name.to_s.should == 'Atta'
      end
    end

  end

  describe "Editable reference tag" do
    it "should return the tag" do
      reference = FactoryGirl.create :article_reference
      reference.stub(:key).and_return 'Latreille, 1809'
      reference.stub(:id).and_return '1234'
      editable_key = Taxt.id_for_editable reference.id
      Taxt.to_editable_reference(reference).should == '{Latreille, 1809 Ut}'
    end
  end
  describe "Editable taxt" do
    describe "To editable taxt" do
      it "should use the inline citation format followed by the id" do
        key = mock 'key'
        key.should_receive(:to_s).and_return 'Fisher, 1922'
        reference = mock 'reference', id: 36
        Reference.should_receive(:find).and_return reference
        reference.stub(:key).and_return key
        editable_key = Taxt.id_for_editable reference.id
        Taxt.to_editable("{ref #{reference.id}}").should == "{Fisher, 1922 #{editable_key}}"
      end
      it "should handle a missing reference" do
        reference = FactoryGirl.create :missing_reference, citation: 'Fisher, 2011'
        editable_key = Taxt.id_for_editable reference.id
        Taxt.to_editable("{ref #{reference.id}}").should == "{Fisher, 2011 #{editable_key}}"
      end
      it "should handle a reference we don't even know is missing" do
        Taxt.to_editable("{ref 123}").should == "{Zb}"
      end
    end
    describe "From editable taxt" do
      it "should use the inline citation format followed by the id" do
        reference = FactoryGirl.create :article_reference
        editable_key = Taxt.id_for_editable reference.id
        Taxt.from_editable("{Fisher, 1922 #{editable_key}}").should == "{ref #{reference.id}}"
      end
      it "should handle more than one reference" do
        reference = FactoryGirl.create :article_reference
        other_reference = FactoryGirl.create :article_reference
        editable_key = Taxt.id_for_editable reference.id
        other_editable_key = Taxt.id_for_editable other_reference.id
        Taxt.from_editable("{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}").should == "{ref #{reference.id}}, also {ref #{other_reference.id}}"
      end
      it "should raise an exception if a reference can't be found and include the failing tag" do
        expect {Taxt.from_editable('asdf {123}')}.to raise_error Taxt::ReferenceNotFound, '{123}'
      end
    end
  end

  describe "String output" do
    it "should leave alone a string without fields" do
      string = Taxt.to_string 'foo', nil
      string.should == 'foo'
      string.should be_html_safe
    end
    it "should handle nil" do
      Taxt.to_string(nil, nil).should == ''
    end
    it "should format a ref" do
      reference = FactoryGirl.create :article_reference
      Reference.should_receive(:find).with(reference.id.to_s).and_return reference
      key_stub = stub
      reference.should_receive(:key).and_return key_stub
      key_stub.should_receive(:to_link).and_return('foo')
      Taxt.to_string("{ref #{reference.id}}", nil).should == 'foo'
    end
    it "should not freak if the ref is malformed" do
      Taxt.to_string("{ref sdf}", nil).should == '{ref sdf}'
    end
    it "should not freak if the ref points to a reference that doesn't exist" do
      Taxt.to_string("{ref 12345}", nil).should == '{ref 12345}'
    end
    it "should handle a MissingReference" do
      reference = FactoryGirl.create :missing_reference, :citation => 'Latreille, 1809'
      Taxt.to_string("{ref #{reference.id}}", nil).should == 'Latreille, 1809'
    end
  end

  describe "Sentence output" do
    before do
      @reference = FactoryGirl.create :missing_reference, :citation => 'Latreille, 1809'
    end
    it "should add a period" do
      Taxt.to_sentence("{ref #{@reference.id}}", nil).should == 'Latreille, 1809.'
    end
    it "should not add a period if one's already there" do
      Taxt.to_sentence("{ref #{@reference.id}}.", nil).should == 'Latreille, 1809.'
    end
  end

end
