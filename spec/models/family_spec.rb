# coding: UTF-8
require 'spec_helper'

describe Family do

  describe "Importing" do
    describe "When the database is empty" do
      it "should create the Family, Protonym, and Citation, and should link to the right Genus and Reference" do
        reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
        data =  {
          :protonym => {
            :family_or_subfamily_name => "Formicariae",
            :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
          },
          :type_genus => {
            :genus_name => 'Formica',
            :texts => [{:text => [{:phrase => ', by monotypy'}]}]
          },
          :history => ["Formicidae as family"]
        }

        family = Family.import data
        family.name.to_s.should == 'Formicidae'
        family.should_not be_invalid
        family.should_not be_fossil
        family.history_items.map(&:taxt).should == ['Formicidae as family']

        family.type_name.to_s.should == 'Formica'
        family.type_name.rank.should == 'genus'
        family.type_taxt.should == ', by monotypy'

        protonym = family.protonym
        protonym.name.to_s.should == 'Formicariae'

        authorship = protonym.authorship
        authorship.pages.should == '124'

        authorship.reference.should == reference
      end
      it "should save the note (when there's not a type taxon note)" do
        reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
        data =  {
          :protonym => {
            :family_or_subfamily_name => "Formicariae",
            :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
          },
          :type_genus => {:genus_name => 'Formica'},
          :note => [{:phrase=>"[Note.]"}],
          :history => ["Formicidae as family"]
        }

        family = Family.import(data).reload
        family.name.to_s.should == 'Formicidae'
        family.should_not be_invalid
        family.should_not be_fossil
        family.history_items.map(&:taxt).should == ['Formicidae as family']

        family.headline_notes_taxt.should == '[Note.]'

        protonym = family.protonym
        protonym.name.to_s.should == 'Formicariae'

        authorship = protonym.authorship
        authorship.pages.should == '124'

        authorship.reference.should == reference
      end
    end

    describe "When the family exists" do
      before do
        @eciton_name = create_name 'Eciton'
        @bolla_name = create_name 'Bolla'

        reference = FactoryGirl.create :article_reference,
          author_names: [Factory(:author_name, name: "Latreille")], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
        @ref_taxt = "{ref #{reference.id}}"
        @atta_name = create_name 'Atta'
        @nam_taxt = "{nam #{@atta_name.id}}"

        citation = Citation.create! reference: reference, pages: '12', forms: 'w.'
        @protonym = Protonym.create!(
          name:         Name.import(family_or_subfamily_name: 'Formicariae'),
          sic:          false,
          fossil:       false,
          authorship:   citation,
          locality:     'CANADA'
        )

        # create a Family
        name = FamilyName.create! name: 'Formicidae'
        @family = Family.create!(
          name: name,
          status: 'valid',
          protonym: @protonym,
          headline_notes_taxt: @ref_taxt,
          type_taxt: @ref_taxt,
          type_fossil: false,
          type_name: @eciton_name
        )
        @history_item = @family.history_items.create! taxt: "1st history item"

        ants_reference_for_title = FactoryGirl.create :article_reference,
          author_names: [Factory(:author_name, name: "Fisher")], citation_year: '2001', bolton_key_cache: 'Fisher 2001'
        @ants_title_taxt = "{ref #{ants_reference_for_title.id}}"
        ants_reference_for_subtitle = FactoryGirl.create :article_reference,
          author_names: [Factory(:author_name, name: "Shattuck")], citation_year: '2009', bolton_key_cache: 'Shattuck 2009'
        @ants_subtitle_taxt = "{ref #{ants_reference_for_subtitle.id}}"
        ants_reference_for_references = FactoryGirl.create :article_reference,
          author_names: [Factory(:author_name, name: "Ward")], citation_year: '1995', bolton_key_cache: 'Ward 1995'
        ants_references_taxt = "{ref #{ants_reference_for_references.id}}"
        #@reference_section = @family.reference_sections.create! title_taxt: @ants_title_taxt, subtitle_taxt: @ants_subtitle_taxt, references_taxt: ants_references_taxt
        @reference_section = @family.reference_sections.create! title_taxt: 'References', subtitle_taxt: 'of New Guinea', references_taxt: 'References go here'

        # and data that matches it
        @data = {
          fossil: false,
          status: 'valid',
          protonym: {
            family_or_subfamily_name: "Formicariae",
            sic: false,
            fossil: false,
            authorship: [{author_names: ["Latreille"], year: "1809", pages: '12', forms: 'w.'}],
            locality: 'CANADA',
          },
          note: [{author_names: ["Latreille"], year: "1809"}],
          type_genus: {
            genus_name: 'Eciton',
            fossil: false,
            texts: [{author_names: ["Latreille"], year: "1809"}],
          },
          history: ['1st history item'],
        }
      end

      it "should compare, update and record value fields" do
        data = @data.merge fossil: true, status: 'synonym'

        family = Family.import data

        Update.count.should == 2

        update = Update.find_by_field_name 'fossil'
        update.class_name.should == 'Family'
        update.field_name.should == 'fossil'
        update.record_id.should == family.id
        update.before.should == '0'
        update.after.should == '1'
        family.fossil.should be_true

        update = Update.find_by_field_name 'status'
        update.before.should == 'valid'
        update.after.should == 'synonym'
        family.status.should == 'synonym'
      end

      it "should compare, update and record taxt" do
        data = @data.merge(
          note: [{genus_name: 'Atta'}],
          type_genus: {
            genus_name: 'Eciton',
            fossil: false,
            texts: [{genus_name: 'Atta'}],
          }
        )

        family = Family.import data

        Update.count.should == 2

        update = Update.find_by_field_name 'headline_notes_taxt'
        update.before.should == @ref_taxt
        update.after.should == @nam_taxt
        family.headline_notes_taxt.should == @nam_taxt

        update = Update.find_by_field_name 'type_taxt'
        update.before.should == @ref_taxt
        update.after.should == @nam_taxt
        family.type_taxt.should == @nam_taxt
      end

      it "should set status to valid when updating by default" do
        data = @data.dup
        data.delete :status
        Family.import data
        Update.count.should == 0
      end

      it "should handle the type fields" do
        data = @data.merge(
          type_genus: {
            genus_name: 'Bolla',
            fossil: true,
            texts: [{genus_name: 'Atta'}]
          }
        )
        family = Family.import data
        Update.count.should == 3

        update = Update.find_by_field_name 'type_taxt'
        update.before.should == @ref_taxt
        update.after.should == @nam_taxt
        family.type_taxt.should == @nam_taxt

        update = Update.find_by_field_name 'type_fossil'
        update.before.should == '0'
        update.after.should == '1'
        family.type_fossil.should be_true

        update = Update.find_by_field_name 'type_name'
        update.before.should == 'Eciton'
        update.after.should == 'Bolla'
        family.type_name.should == @bolla_name
      end

      describe "Taxon history" do
        it "should replace existing items when the count is the same" do
          data = @data.merge(
            history: ['1st history item with change']
          )
          family = Family.import data

          Update.count.should == 1

          update = Update.find_by_field_name 'taxt'
          update.class_name.should == 'TaxonHistoryItem'
          update.record_id.should == family.history_items.first.id
          update.before.should == '1st history item'
          update.after.should == '1st history item with change'
          family.history_items.count.should == 1
          family.history_items.first.taxt.should == '1st history item with change'
        end
        it "should append new items" do
          data = @data.merge(
            history: ['1st history item', '2nd history item']
          )
          family = Family.import data

          Update.count.should == 1

          update = Update.find_by_field_name 'taxt'
          update.class_name.should == 'TaxonHistoryItem'
          update.record_id.should == family.history_items.second.id
          update.before.should == nil
          update.after.should == '2nd history item'
          family.history_items.count.should == 2
          family.history_items.first.taxt.should == '1st history item'
          family.history_items.second.taxt.should == '2nd history item'
        end
        it "should delete deleted ones" do
          data = @data.merge(history: [])
          original_id = @family.history_items.first.id

          family = Family.import data

          Update.count.should == 1

          update = Update.find_by_field_name 'taxt'
          update.class_name.should == 'TaxonHistoryItem'
          update.record_id.should == original_id
          update.before.should == nil
          update.after.should == nil
          family.history_items.count.should == 0
        end
      end

      describe "Reference sections" do
        it "should replace existing items when the count is the same, and not convert incoming taxt" do
          reference_sections = [
            {title_taxt: @ants_title_taxt, subtitle_taxt: @ants_subtitle_taxt, references_taxt: @ants_references_taxt},
          ]

          @family.import_reference_sections reference_sections

          Update.count.should == 3

          update = Update.find_by_field_name 'title_taxt'
          update.class_name.should == 'ReferenceSection'
          update.record_id.should == @family.reference_sections.first.id
          update.before.should == 'References'
          update.after.should == @ants_title_taxt

          update = Update.find_by_field_name 'subtitle_taxt'
          update.before.should == 'of New Guinea'
          update.after.should == @ants_subtitle_taxt

          @family.reference_sections.count.should == 1
          @family.reference_sections.first.title_taxt.should == @ants_title_taxt
        end

        it "should append new items" do
          reference_sections = [
            {title_taxt: 'References', subtitle_taxt: 'of New Guinea', references_taxt: 'References go here'},
            {title_taxt: '2nd reference section', subtitle_taxt: '2nd subtitle', references_taxt: '2nd references'},
          ]

          @family.import_reference_sections reference_sections

          Update.count.should == 3

          update = Update.find_by_field_name 'title_taxt'
          update.class_name.should == 'ReferenceSection'
          update.record_id.should == @family.reference_sections.second.id
          update.before.should == nil
          update.after.should == '2nd reference section'
          @family.reference_sections.count.should == 2
          @family.reference_sections.first.title_taxt.should == 'References'
          @family.reference_sections.second.title_taxt.should == '2nd reference section'
        end
        it "should delete deleted ones" do
          reference_sections = []
          original_id = @family.reference_sections.first.id

          @family.import_reference_sections reference_sections

          Update.count.should == 1

          update = Update.find_by_class_name_and_record_id 'ReferenceSection', original_id
          update.field_name.should be_nil
          update.before.should be_nil
          update.after.should be_nil
          @family.reference_sections.count.should == 0
        end
      end

      describe "Protonym" do
        it "should handle value fields" do
          data = @data.dup
          data[:protonym][:sic] = true
          data[:protonym][:fossil] = true
          data[:protonym][:locality] = 'U.S.A.'

          family = Family.import data

          Update.count.should == 3

          update = Update.find_by_field_name 'sic'
          update.class_name.should == 'Protonym'
          update.record_id.should == @protonym.id
          update.before.should == '0'
          update.after.should == '1'
          family.protonym.sic.should be_true

          update = Update.find_by_field_name 'fossil'
          update.class_name.should == 'Protonym'
          update.record_id.should == @protonym.id
          update.before.should == '0'
          update.after.should == '1'
          family.protonym.fossil.should be_true

          update = Update.find_by_field_name 'locality'
          update.class_name.should == 'Protonym'
          update.record_id.should == @protonym.id
          update.before.should == 'CANADA'
          update.after.should == 'U.S.A.'
          family.protonym.locality.should be_true

        end

        it "should compare, record and update its name" do
          data = @data.dup
          data[:protonym][:family_or_subfamily_name] = 'Formicadiae'

          family = Family.import data

          Update.count.should == 1

          update = Update.find_by_field_name 'name'
          update.before.should == 'Formicariae'
          update.after.should == 'Formicadiae'
          family.protonym.name.name.should == 'Formicadiae'
        end

      end

      describe "Citation" do
        it "should record changes in notes_taxt" do
          data = @data.dup
          data[:protonym][:authorship][0][:notes] = [[{genus_name: 'Atta'}]]
          family = Family.import data
          update = Update.find_by_field_name 'notes_taxt'
          update.class_name.should == 'Citation'
          update.before.should == nil
          update.after.should == " (#{@nam_taxt})"
          family.protonym.authorship.notes_taxt.should == " (#{@nam_taxt})"
        end
        it "should record changes in value fields" do
          data = @data.dup
          citation = data[:protonym][:authorship][0]
          citation[:forms] = 'q.'
          citation[:pages] = '100'

          family = Family.import data

          Update.count.should == 2

          update = Update.find_by_field_name 'pages'
          update.class_name.should == 'Citation'
          update.before.should == '12'
          update.after.should == '100'
          family.protonym.authorship.pages.should == '100'

          update = Update.find_by_field_name 'forms'
          update.before.should == 'w.'
          update.after.should == 'q.'
          family.protonym.authorship.forms.should == 'q.'
        end
        it "should record a different reference than before" do
          new_reference = FactoryGirl.create :article_reference,
            author_names: [Factory(:author_name, name: 'Bolton')], citation_year: '2005', bolton_key_cache: 'Bolton 2005'
          data = @data.dup
          data[:protonym][:authorship].first[:author_names] = ['Bolton, B.']
          data[:protonym][:authorship].first[:year] = '2005'

          family = Family.import data

          Update.count.should == 1

          update = Update.find_by_field_name 'reference'
          update.class_name.should == 'Citation'
          update.before.should == 'Latreille, 1809'
          update.after.should == 'Bolton, 2005'
          family.protonym.authorship.reference.principal_author_last_name.should == 'Bolton'
        end
      end

    end
  end

  describe "Statistics" do
    it "should return the statistics for each status of each rank" do
      family = FactoryGirl.create :family
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => tribe
      FactoryGirl.create :genus, :subfamily => subfamily, :status => 'homonym', :tribe => tribe
      2.times {FactoryGirl.create :subfamily, :fossil => true}
      family.statistics.should == {
        :extant => {subfamilies: {'valid' => 1}, tribes: {'valid' => 1}, genera: {'valid' => 1, 'homonym' => 1}},
        :fossil => {subfamilies: {'valid' => 2}}
      }
    end
  end

  describe "Label" do
    it "should be the family name" do
      FactoryGirl.create(:family, name: FactoryGirl.create(:name, name: 'Formicidae')).name.to_html.should == 'Formicidae'
    end
  end

  describe "Genera" do
    it "should include genera without subfamilies" do
      family = create_family
      subfamily = create_subfamily
      genus_without_subfamily = create_genus subfamily: nil
      genus_with_subfamily = create_genus subfamily: subfamily
      family.genera.should == [genus_without_subfamily]
    end
  end

  describe "Subfamilies" do
    it "should include all the subfamilies" do
      family = create_family
      subfamily = create_subfamily
      family.subfamilies.should == [subfamily]
    end
  end

end
