require 'spec_helper'

describe Taxt do
  describe "Editable taxt" do
    describe ".to_editable" do
      context "References" do
        it "uses the inline citation format followed by the id, with type number" do
          decorated = double 'key'
          reference = double 'reference', id: 36
          expect(reference).to receive(:decorate).and_return decorated
          expect(decorated).to receive(:key).and_return 'Fisher, 1922'
          expect(Reference).to receive(:find).and_return reference
          editable_key = Taxt.send :id_for_editable, reference.id, 1

          expect(Taxt.to_editable("{ref #{reference.id}}")).to eq "{Fisher, 1922 #{editable_key}}"
        end

        it "handles missing references" do
          reference = create :missing_reference, citation: 'Fisher, 2011'
          editable_key = Taxt.send :id_for_editable, reference.id, 1
          expect(Taxt.to_editable("{ref #{reference.id}}")).to eq "{Fisher, 2011 #{editable_key}}"
        end

        it "handles references we don't even know are missing" do
          expect(Taxt.to_editable("{ref 123}")).to eq "{Rt}"
        end
      end

      context "Taxa" do
        it "uses the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.send :id_for_editable, genus.id, 2
          expect(Taxt.to_editable("{tax #{genus.id}}")).to eq "{Atta #{editable_key}}"
        end
      end

      context "Names" do
        it "uses the name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.send :id_for_editable, genus.name.id, 3
          expect(Taxt.to_editable("{nam #{genus.name.id}}")).to eq "{Atta #{editable_key}}"
        end
      end
    end

    describe ".from_editable" do
      describe "{ref}" do
        it "uses the inline citation format followed by the id" do
          reference = create :article_reference
          editable_key = Taxt.send :id_for_editable, reference.id, 1
          expect(Taxt.from_editable("{Fisher, 1922 #{editable_key}}")).to eq "{ref #{reference.id}}"
        end

        it "handles more than one reference" do
          reference = create :article_reference
          other_reference = create :article_reference
          editable_key = Taxt.send :id_for_editable, reference.id, 1
          other_editable_key = Taxt.send :id_for_editable, other_reference.id, 1

          results = Taxt.from_editable "{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}"
          expect(results).to eq "{ref #{reference.id}}, also {ref #{other_reference.id}}"
        end
      end

      context "Taxa" do
        it "uses the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_key = Taxt.send :id_for_editable, genus.id, 2
          expect(Taxt.from_editable("{Atta #{editable_key}}")).to eq "{tax #{genus.id}}"
        end
      end
    end
  end

  describe ".to_string" do
    it "ignores strings without fields" do
      string = Taxt.to_string 'foo'
      expect(string).to eq 'foo'
      expect(string).to be_html_safe
    end

    #it "escapes its input" do
      #string = Taxt.to_string '<script>'
      #string.should == '&lt;script&gt;'
      #string.should be_html_safe
    #end

    it "handles nil" do
      expect(Taxt.to_string(nil)).to eq ''
    end

    describe "Reference" do
      describe "Linked" do
        # Uncommented because randomly fails/succeeds.
        #it "can format a ref", pending: true do
        #  pending "broke for some mysterious reason"
        #  # `expect(Reference).to receive(:find).with(reference.id.to_s)`
        #  # --> expected: ("14") got: (14)
        #  #
        #  # Easy peasy, let's just remove that `.to_s`:
        #  # `expect(Reference).to receive(:find).with(reference.id)`
        #  # --> expected: (14) got: ("14")
        #  #
        #  # Hmmm...

        #  reference = create :article_reference
        #  decorated = reference.decorate
        #  expect(Reference).to receive(:find).with(reference.id.to_s).and_return reference
        #  expect(reference).to receive(:decorate).and_return decorated
        #  expect(decorated).to receive(:to_link).and_return 'foo'
        #  expect(Taxt.to_string("{ref #{reference.id}}")).to eq 'foo'
        #end

        it "doesn't freak if the ref is malformed" do
          expect(Taxt.to_string("{ref sdf}")).to eq '{ref sdf}'
        end

        it "doesn't freak if the ref points to a reference that doesn't exist" do
          expect { expect(Taxt.to_string("{ref 12345}")).to eq('{ref 12345}') }.not_to raise_error
          expect(Taxt.to_string("{ref 12345}")).to eq '{ref 12345}'
        end

        it "handles a MissingReference" do
          reference = create :missing_reference, citation: 'Latreille, 1809'
          expect(Taxt.to_string("{ref #{reference.id}}")).to eq 'Latreille, 1809'
        end

        #it "escapes input" do
          #reference = create :missing_reference, citation: 'Latreille, 1809 <script>'
          #Taxt.to_string("{ref #{reference.id}}").should == 'Latreille, 1809 &lt;script&gt;'
        #end
      end
    end

    describe "Name" do
      describe "Links" do
        it "returns the HTML version of the name" do
          name = create :subspecies_name, name_html: '<i>Atta major minor</i>'
          expect(Taxt.to_string("{nam #{name.id}}")).to eq '<i>Atta major minor</i>'
        end

        it "doesn't freak if the name can't be found" do
          expect(Taxt.to_string("{nam 12345}")).to eq '{nam 12345}'
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

      it "can use a different link formatter" do
        genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
        expect(Taxt).to receive :link_to_antcat_from_antweb
        Taxt.to_string "{tax #{genus.id}}" # Doesn't do anything...
      end
    end

    describe "Taxon" do
      describe "Linked" do
        it "uses the HTML version of the taxon's name" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
          expect(Taxt.to_string("{tax #{genus.id}}"))
            .to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
        end

        it "includes the fossil symbol if applicable" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>'), fossil: true
          expect(Taxt.to_string("{tax #{genus.id}}"))
            .to eq %{<a href="/catalog/#{genus.id}"><i>&dagger;</i><i>Atta</i></a>}
        end

        it "doesn't freak if the taxon can't be found" do
          expect(Taxt.to_string("{tax 12345}")).to eq '{tax 12345}'
        end

        it "uses the HTML version of the taxon's name" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
          expect(Taxt.to_string("{tax #{genus.id}}"))
            .to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
        end
      end
    end
  end
end
