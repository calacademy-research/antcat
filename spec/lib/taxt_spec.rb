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

    describe "Encoding a taxon" do
      it "should encode a taxon" do
        genus = create_genus
        Taxt.encode_taxon(genus).should == "{tax #{genus.id}}"
      end
    end

    describe "Encoding a taxon name" do

      describe "Creating/using Names" do
        it "should create a name if necessary" do
          Name.count.should == 0
          taxt = Taxt.encode_taxon_name genus_name: 'Atta'
          Name.count.should == 1
          taxt.should == "{nam #{Name.first.id}}"
        end
        it "should not use a word from the spurious list" do
          Taxt.encode_taxon_name(genus_name: 'Nomen', species_epithet: 'nudum').should == "<i>Nomen nudum</i>"
        end
        it "should reuse a name if possible" do
          create_name 'Atta'
          Name.count.should == 1
          taxt = Taxt.encode_taxon_name genus_name: 'Atta'
          Name.count.should == 1
          taxt.should == "{nam #{Name.first.id}}"
        end
      end

      it "should create a {tax} if the taxon is found" do
        genus = create_genus 'Atta'
        Taxt.encode_taxon_name(genus_name: 'Atta').should == "{tax #{genus.id}}"
      end

      it "should create a {nam 1234} tag, pointing to the Name" do
        name = create_name 'Atta'
        Taxt.encode_taxon_name(genus_name: 'Atta').should == "{nam #{name.id}}"
      end
      it "should handle a family-group name" do
        name = create_name 'Dolichoderinae'
        Taxt.encode_taxon_name(family_or_subfamily_name: 'Dolichoderinae').should == "{nam #{name.id}}"
      end
      it "should handle a genus name" do
        name = create_name 'Atta'
        Taxt.encode_taxon_name(genus_name: 'Atta').should == "{nam #{name.id}}"
      end
      it "should handle a species name" do
        name = create_name 'Eoformica eofornica'
        Taxt.encode_taxon_name(genus_name: 'Eoformica', species_epithet: 'eofornica').should == "{nam #{name.id}}"
      end
      it "should handle a genus name + subgenus epithet" do
        name = create_name 'Acanthostichus (Ctenopyga)'
        Taxt.encode_taxon_name(genus_name: 'Acanthostichus', subgenus_epithet: 'Ctenopyga').should == "{nam #{name.id}}"
      end
      it "should handle a genus name object + subgenus epithet" do
        genus = create_genus 'Camponotus'
        name = create_name 'Camponotus (Ctenopyga)'
        Taxt.encode_taxon_name(genus_name: genus.name, subgenus_epithet: 'Ctenopyga').should == "{nam #{name.id}}"
      end
      it "should handle a species name with subgenus" do
        name = create_name 'Formica subspinosa'
        Taxt.encode_taxon_name(genus_name: 'Formica', subgenus_epithet: 'Hypochira', species_epithet: 'subspinosa').should == "{nam #{name.id}}"
      end
      it "should handle a subspecies name" do
        name = FactoryGirl.create :subspecies_name, name: 'Eoformica eofornica major'
        rc = Taxt.encode_taxon_name(genus_name: 'Eoformica', species_epithet: 'eofornica', subspecies: [{subspecies_epithet: 'major'}])
        rc.should == "{nam #{name.id}}"
      end

    end
  end

  describe "Editable taxt" do

    describe "To editable taxt" do
      describe "References" do
        it "should use the inline citation format followed by the id, with type number" do
          key = double 'key'
          key.should_receive(:to_s).and_return 'Fisher, 1922'
          reference = double 'reference', id: 36
          Reference.should_receive(:find).and_return reference
          reference.stub(:key).and_return key
          editable_key = Taxt.id_for_editable reference.id, 1
          Taxt.to_editable("{ref #{reference.id}}").should == "{Fisher, 1922 #{editable_key}}"
        end
        it "should handle a missing reference" do
          reference = FactoryGirl.create :missing_reference, citation: 'Fisher, 2011'
          editable_key = Taxt.id_for_editable reference.id, 1
          Taxt.to_editable("{ref #{reference.id}}").should == "{Fisher, 2011 #{editable_key}}"
        end
        it "should handle a reference we don't even know is missing" do
          Taxt.to_editable("{ref 123}").should == "{Rt}"
        end
      end
      describe "Taxa" do
        it "should use the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.id_for_editable genus.id, 2
          Taxt.to_editable("{tax #{genus.id}}").should == "{Atta #{editable_key}}"
        end
      end
      describe "Names" do
        it "should use the name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.id_for_editable genus.name.id, 3
          Taxt.to_editable("{nam #{genus.name.id}}").should == "{Atta #{editable_key}}"
        end
      end
    end

    describe "From editable taxt" do
      describe "{ref}" do
        it "should use the inline citation format followed by the id" do
          reference = FactoryGirl.create :article_reference
          editable_key = Taxt.id_for_editable reference.id, 1
          Taxt.from_editable("{Fisher, 1922 #{editable_key}}").should == "{ref #{reference.id}}"
        end
        it "should handle more than one reference" do
          reference = FactoryGirl.create :article_reference
          other_reference = FactoryGirl.create :article_reference
          editable_key = Taxt.id_for_editable reference.id, 1
          other_editable_key = Taxt.id_for_editable other_reference.id, 1
          Taxt.from_editable("{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}").should == "{ref #{reference.id}}, also {ref #{other_reference.id}}"
        end
      end
      describe "Taxa" do
        it "should use the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.id_for_editable genus.id, 2
          Taxt.from_editable("{Atta #{editable_key}}").should == "{tax #{genus.id}}"
        end
      end
    end
  end

  describe "String output" do

    it "should leave alone a string without fields" do
      string = Taxt.to_string 'foo'
      string.should == 'foo'
      string.should be_html_safe
    end
    #it "should escape its input" do
      #string = Taxt.to_string '<script>'
      #string.should == '&lt;script&gt;'
      #string.should be_html_safe
    #end
    it "should handle nil" do
      Taxt.to_string(nil).should == ''
    end

    describe "Reference" do
      describe "Linked" do
        it "should format a ref" do
          reference = FactoryGirl.create :article_reference
          Reference.should_receive(:find).with(reference.id.to_s).and_return reference
          key_stub = double
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
        #it "should escape input" do
          #reference = FactoryGirl.create :missing_reference, citation: 'Latreille, 1809 <script>'
          #Taxt.to_string("{ref #{reference.id}}", nil).should == 'Latreille, 1809 &lt;script&gt;'
        #end
      end
      describe "Display" do
        it "should format a ref" do
          reference = FactoryGirl.create :article_reference
          Reference.should_receive(:find).with(reference.id.to_s).and_return reference
          key_stub = double
          reference.should_receive(:key).and_return key_stub
          key_stub.should_receive(:to_s).and_return('foo')
          Taxt.to_display_string("{ref #{reference.id}}", nil).should == 'foo'
        end
      end
    end

    describe "Name" do
      describe "Links" do
        it "should return the HTML version of the name" do
          name = FactoryGirl.create :subspecies_name, name_html: '<i>Atta major minor</i>'
          Taxt.to_string("{nam #{name.id}}").should == '<i>Atta major minor</i>'
        end
        it "should not freak if the name can't be found" do
          Taxt.to_string("{nam 12345}").should == '{nam 12345}'
        end
      end
      describe "Display" do
        it "should return the HTML version of the name" do
          name = FactoryGirl.create :subspecies_name, name_html: '<i>Atta major minor</i>'
          Taxt.to_display_string("{nam #{name.id}}").should == '<i>Atta major minor</i>'
        end
      end
    end

    describe "Taxon" do
      describe "Linked" do
        it "should use the HTML version of the taxon's name" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          Taxt.to_string("{tax #{genus.id}}").should == %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
        end
        it "should be able to use a different link formatter" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          formatter = double
          formatter.should_receive :link_to_taxon
          Taxt.to_string("{tax #{genus.id}}", nil, formatter: formatter)
        end
        it "should include the fossil symbol if applicable" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>'), fossil: true
          Taxt.to_string("{tax #{genus.id}}").should == %{<a href="/catalog/#{genus.id}"><i>&dagger;</i><i>Atta</i></a>}
        end
        it "should not freak if the taxon can't be found" do
          Taxt.to_string("{tax 12345}").should == '{tax 12345}'
        end
        it "should use the HTML version of the taxon's name" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          Taxt.to_string("{tax #{genus.id}}").should == %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
        end
      end
      describe "Display" do
        it "should use the HTML version of the taxon's name" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          Taxt.to_display_string("{tax #{genus.id}}").should == %{<i>Atta</i>}
        end
      end
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

  describe "Cleanup" do
    before do
      @america = create_name 'America'
      @genus = create_genus
    end
    it "should change these fields in these tables" do
      taxon = FactoryGirl.create :genus,
                         type_taxt: "{nam #{@america.id}}",
                         headline_notes_taxt: "{nam #{@america.id}}",
                         genus_species_header_notes_taxt: "{nam #{@america.id}}"

      taxon.protonym.authorship.notes_taxt = "{nam #{@america.id}}"
      taxon.protonym.authorship.save!

      reference_section = ReferenceSection.create! title_taxt: "{nam #{@america.id}}",
                               subtitle_taxt: "{nam #{@america.id}}",
                               references_taxt: "{nam #{@america.id}}"
      history_item = TaxonHistoryItem.create! taxt: "{nam #{@america.id}}"

      Taxt.cleanup

      taxon.reload
      taxon.type_taxt.should == 'America'
      taxon.headline_notes_taxt.should ==  'America'
      taxon.genus_species_header_notes_taxt.should == 'America'

      taxon.protonym.authorship.notes_taxt.should == 'America'

      reference_section.reload
      reference_section.title_taxt.should == 'America'
      reference_section.subtitle_taxt.should ==  'America'
      reference_section.references_taxt.should == 'America'

      history_item.reload
      history_item.taxt.should == 'America'
    end

    it "should replace spurious {nam}s with the word" do
      Taxt.cleanup_field("{nam #{@america.id}}").should == 'America'
    end

    it "should replace {nam}s with {tax}s where possible" do
      Taxt.cleanup_field("{nam #{@genus.name.id}}").should == "{tax #{@genus.id}}"
    end

    it "should leave {nam}s alone that don't match a taxt" do
      name = create_name 'Atta'
      Taxt.cleanup_field("{nam #{name.id}}").should == "{nam #{name.id}}"
    end

    it "should handle more than one replacement in same string" do
      Taxt.cleanup_field("{nam #{@america.id}}, {nam #{@genus.name.id}}").should == "America, {tax #{@genus.id}}"
    end
  end

end
