require 'spec_helper'

describe Taxt do

  describe "Encodings" do
    it "should encode an unparseable string", pending: true do
      pending "is this used outside of specs?" # TODO remove?
      expect(Taxt.encode_unparseable('foo')).to eq('{? foo}')
    end
    it "should encode a reference", pending: true do
      pending "Taxt.encode_reference likely only used in this spec" # TODO remove?
      reference = FactoryGirl.create :book_reference
      expect(Taxt.encode_reference(reference)).to eq("{ref #{reference.id}}")
    end

    describe "Encoding a taxon" do
      it "should encode a taxon", pending: true do
        pending "is this used outside of specs?" # TODO remove?
        genus = create_genus
        expect(Taxt.encode_taxon(genus)).to eq("{tax #{genus.id}}")
      end
    end
  end

  describe "Editable taxt" do

    describe "To editable taxt" do
      describe "References" do
        it "should use the inline citation format followed by the id, with type number" do
          key = double 'key'
          expect(key).to receive(:to_s).and_return 'Fisher, 1922'
          reference = double 'reference', id: 36
          expect(Reference).to receive(:find).and_return reference
          allow(reference).to receive(:key).and_return key
          editable_key = Taxt.id_for_editable reference.id, 1
          expect(Taxt.to_editable("{ref #{reference.id}}")).to eq("{Fisher, 1922 #{editable_key}}")
        end
        it "should handle a missing reference" do
          reference = FactoryGirl.create :missing_reference, citation: 'Fisher, 2011'
          editable_key = Taxt.id_for_editable reference.id, 1
          expect(Taxt.to_editable("{ref #{reference.id}}")).to eq("{Fisher, 2011 #{editable_key}}")
        end
        it "should handle a reference we don't even know is missing" do
          expect(Taxt.to_editable("{ref 123}")).to eq("{Rt}")
        end
      end
      describe "Taxa" do
        it "should use the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.id_for_editable genus.id, 2
          expect(Taxt.to_editable("{tax #{genus.id}}")).to eq("{Atta #{editable_key}}")
        end
      end
      describe "Names" do
        it "should use the name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.id_for_editable genus.name.id, 3
          expect(Taxt.to_editable("{nam #{genus.name.id}}")).to eq("{Atta #{editable_key}}")
        end
      end
    end

    describe "From editable taxt" do
      describe "{ref}" do
        it "should use the inline citation format followed by the id" do
          reference = FactoryGirl.create :article_reference
          editable_key = Taxt.id_for_editable reference.id, 1
          expect(Taxt.from_editable("{Fisher, 1922 #{editable_key}}")).to eq("{ref #{reference.id}}")
        end
        it "should handle more than one reference" do
          reference = FactoryGirl.create :article_reference
          other_reference = FactoryGirl.create :article_reference
          editable_key = Taxt.id_for_editable reference.id, 1
          other_editable_key = Taxt.id_for_editable other_reference.id, 1
          expect(Taxt.from_editable("{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}")).to eq("{ref #{reference.id}}, also {ref #{other_reference.id}}")
        end
      end
      describe "Taxa" do
        it "should use the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.id_for_editable genus.id, 2
          expect(Taxt.from_editable("{Atta #{editable_key}}")).to eq("{tax #{genus.id}}")
        end
      end
    end
  end

  describe "String output" do

    it "should leave alone a string without fields" do
      string = Taxt.to_string 'foo'
      expect(string).to eq('foo')
      expect(string).to be_html_safe
    end
    #it "should escape its input" do
      #string = Taxt.to_string '<script>'
      #string.should == '&lt;script&gt;'
      #string.should be_html_safe
    #end
    it "should handle nil" do
      expect(Taxt.to_string(nil)).to eq('')
    end

    describe "Reference" do
      describe "Linked" do
        it "should format a ref" do
          reference = FactoryGirl.create :article_reference
          expect(Reference).to receive(:find).with(reference.id.to_s).and_return reference
          key_stub = double
          expect(reference).to receive(:key).and_return key_stub
          expect(key_stub).to receive(:to_link).and_return('foo')
          expect(Taxt.to_string("{ref #{reference.id}}", nil)).to eq('foo')
        end
        it "should not freak if the ref is malformed" do
          expect(Taxt.to_string("{ref sdf}", nil)).to eq('{ref sdf}')
        end
        it "should not freak if the ref points to a reference that doesn't exist" do
          expect {expect(Taxt.to_string("{ref 12345}", nil)).to eq('{ref 12345}')}.not_to raise_error
          expect(Taxt.to_string("{ref 12345}", nil)).to eq('{ref 12345}')
        end
        it "should handle a MissingReference" do
          reference = FactoryGirl.create :missing_reference, :citation => 'Latreille, 1809'
          expect(Taxt.to_string("{ref #{reference.id}}", nil)).to eq('Latreille, 1809')
        end
        #it "should escape input" do
          #reference = FactoryGirl.create :missing_reference, citation: 'Latreille, 1809 <script>'
          #Taxt.to_string("{ref #{reference.id}}", nil).should == 'Latreille, 1809 &lt;script&gt;'
        #end
      end
      describe "Display" do
        it "should format a ref" do
          reference = FactoryGirl.create :article_reference
          expect(Reference).to receive(:find).with(reference.id.to_s).and_return reference
          key_stub = double
          expect(reference).to receive(:key).and_return key_stub
          expect(key_stub).to receive(:to_s).and_return('foo')
          expect(Taxt.to_display_string("{ref #{reference.id}}", nil)).to eq('foo')
        end
      end
    end

    describe "Name" do
      describe "Links" do
        it "should return the HTML version of the name" do
          name = FactoryGirl.create :subspecies_name, name_html: '<i>Atta major minor</i>'
          expect(Taxt.to_string("{nam #{name.id}}")).to eq('<i>Atta major minor</i>')
        end
        it "should not freak if the name can't be found" do
          expect(Taxt.to_string("{nam 12345}")).to eq('{nam 12345}')
        end
      end
      describe "Display" do
        it "should return the HTML version of the name" do
          name = FactoryGirl.create :subspecies_name, name_html: '<i>Atta major minor</i>'
          expect(Taxt.to_display_string("{nam #{name.id}}")).to eq('<i>Atta major minor</i>')
        end
      end
    end

    describe "AntWeb formatter quirk" do
      before do # TODO cleanup
        $use_ant_web_formatter = true
      end
      after do
        $use_ant_web_formatter = nil
      end

      it "should be able to use a different link formatter" do
        genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
        expect(Taxt).to receive :link_to_antcat_from_antweb
        Taxt.to_string("{tax #{genus.id}}", nil)
      end
    end

    describe "Taxon" do
      describe "Linked" do
        it "should use the HTML version of the taxon's name" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          expect(Taxt.to_string("{tax #{genus.id}}")).to eq(%{<a href="/catalog/#{genus.id}"><i>Atta</i></a>})
        end

        it "should include the fossil symbol if applicable" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>'), fossil: true
          expect(Taxt.to_string("{tax #{genus.id}}")).to eq(%{<a href="/catalog/#{genus.id}"><i>&dagger;</i><i>Atta</i></a>})
        end
        it "should not freak if the taxon can't be found" do
          expect(Taxt.to_string("{tax 12345}")).to eq('{tax 12345}')
        end
        it "should use the HTML version of the taxon's name" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          expect(Taxt.to_string("{tax #{genus.id}}")).to eq(%{<a href="/catalog/#{genus.id}"><i>Atta</i></a>})
        end
      end
      describe "Display" do
        it "should use the HTML version of the taxon's name" do
          genus = create_genus name: FactoryGirl.create(:genus_name, name_html: '<i>Atta</i>')
          expect(Taxt.to_display_string("{tax #{genus.id}}")).to eq(%{<i>Atta</i>})
        end
      end
    end
  end

  describe "Sentence output" do
    let(:reference) { FactoryGirl.create :missing_reference, :citation => 'Latreille, 1809' }

    it "should add a period" do
      expect(Taxt.to_sentence("{ref #{reference.id}}", nil)).to eq('Latreille, 1809.')
    end
    it "should not add a period if one's already there" do
      expect(Taxt.to_sentence("{ref #{reference.id}}.", nil)).to eq('Latreille, 1809.')
    end
  end

end
