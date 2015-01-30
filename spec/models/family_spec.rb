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
        expect(family.name.to_s).to eq('Formicidae')
        expect(family).not_to be_invalid
        expect(family).not_to be_fossil
        expect(family.history_items.map(&:taxt)).to eq(['Formicidae as family'])

        expect(family.type_name.to_s).to eq('Formica')
        expect(family.type_name.rank).to eq('genus')
        expect(family.type_taxt).to eq(', by monotypy')

        protonym = family.protonym
        expect(protonym.name.to_s).to eq('Formicariae')

        authorship = protonym.authorship
        expect(authorship.pages).to eq('124')

        expect(authorship.reference).to eq(reference)

        expect(Update.count).to eq(1)
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
        expect(family.name.to_s).to eq('Formicidae')
        expect(family).not_to be_invalid
        expect(family).not_to be_fossil
        expect(family.history_items.map(&:taxt)).to eq(['Formicidae as family'])

        expect(family.headline_notes_taxt).to eq('[Note.]')

        protonym = family.protonym
        expect(protonym.name.to_s).to eq('Formicariae')

        authorship = protonym.authorship
        expect(authorship.pages).to eq('124')

        expect(authorship.reference).to eq(reference)
      end
    end

    describe "When the family exists" do
      before do
        @eciton_name = create_name 'Eciton'
        @bolla_name = create_name 'Bolla'

        reference = FactoryGirl.create :article_reference,
          author_names: [FactoryGirl.create(:author_name, name: "Latreille")], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
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
          author_names: [FactoryGirl.create(:author_name, name: "Fisher")], citation_year: '2001', bolton_key_cache: 'Fisher 2001'
        @ants_title_taxt = "{ref #{ants_reference_for_title.id}}"
        ants_reference_for_subtitle = FactoryGirl.create :article_reference,
          author_names: [FactoryGirl.create(:author_name, name: "Shattuck")], citation_year: '2009', bolton_key_cache: 'Shattuck 2009'
        @ants_subtitle_taxt = "{ref #{ants_reference_for_subtitle.id}}"
        ants_reference_for_references = FactoryGirl.create :article_reference,
          author_names: [FactoryGirl.create(:author_name, name: "Ward")], citation_year: '1995', bolton_key_cache: 'Ward 1995'
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
        pending "importers, not germane to core functionality"

        data = @data.merge fossil: true, status: 'synonym'

        family = Family.import data

        expect(Update.count).to eq(2)

        update = Update.find_by_field_name 'fossil'
        expect(update.name).to eq('Formicidae')
        expect(update.class_name).to eq('Family')
        expect(update.field_name).to eq('fossil')
        expect(update.record_id).to eq(family.id)
        expect(update.before).to eq('0')
        expect(update.after).to eq('1')
        expect(family.fossil).to be_truthy

        update = Update.find_by_field_name 'status'
        expect(update.before).to eq('valid')
        expect(update.after).to eq('synonym')
        expect(family.status).to eq('synonym')
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

        expect(Update.count).to eq(2)

        update = Update.find_by_field_name 'headline_notes_taxt'
        expect(update.before).to eq(@ref_taxt)
        expect(update.after).to eq(@nam_taxt)
        expect(family.headline_notes_taxt).to eq(@nam_taxt)

        update = Update.find_by_field_name 'type_taxt'
        expect(update.before).to eq(@ref_taxt)
        expect(update.after).to eq(@nam_taxt)
        expect(family.type_taxt).to eq(@nam_taxt)
      end

      it "should set status to valid when updating by default" do
        data = @data.dup
        data.delete :status
        Family.import data
        expect(Update.count).to eq(0)
      end

      it "should handle the type fields" do
        pending "importers, not germane to core functionality"

        data = @data.merge(
          type_genus: {
            genus_name: 'Bolla',
            fossil: true,
            texts: [{genus_name: 'Atta'}]
          }
        )
        family = Family.import data
        expect(Update.count).to eq(3)

        update = Update.find_by_field_name 'type_taxt'
        expect(update.before).to eq(@ref_taxt)
        expect(update.after).to eq(@nam_taxt)
        expect(family.type_taxt).to eq(@nam_taxt)

        update = Update.find_by_field_name 'type_fossil'
        expect(update.before).to eq('0')
        expect(update.after).to eq('1')
        expect(family.type_fossil).to be_truthy

        update = Update.find_by_field_name 'type_name'
        expect(update.before).to eq('Eciton')
        expect(update.after).to eq('Bolla')
        expect(family.type_name).to eq(@bolla_name)
      end

      describe "Taxon history" do
        it "should replace existing items when the count is the same" do
          data = @data.merge(
            history: ['1st history item with change']
          )
          family = Family.import data

          expect(Update.count).to eq(1)

          update = Update.find_by_field_name 'taxt'
          expect(update.class_name).to eq('TaxonHistoryItem')
          expect(update.record_id).to eq(family.history_items.first.id)
          expect(update.before).to eq('1st history item')
          expect(update.after).to eq('1st history item with change')
          expect(family.history_items.count).to eq(1)
          expect(family.history_items.first.taxt).to eq('1st history item with change')
        end
        it "should append new items" do
          data = @data.merge(
            history: ['1st history item', '2nd history item']
          )
          family = Family.import data

          expect(Update.count).to eq(1)

          update = Update.find_by_field_name 'taxt'
          expect(update.class_name).to eq('TaxonHistoryItem')
          expect(update.record_id).to eq(family.history_items.second.id)
          expect(update.before).to eq(nil)
          expect(update.after).to eq('2nd history item')
          expect(family.history_items.count).to eq(2)
          expect(family.history_items.first.taxt).to eq('1st history item')
          expect(family.history_items.second.taxt).to eq('2nd history item')
        end
        it "should delete deleted ones" do
          data = @data.merge(history: [])
          original_id = @family.history_items.first.id

          family = Family.import data

          expect(Update.count).to eq(1)

          update = Update.find_by_field_name 'delete'
          expect(update.class_name).to eq('TaxonHistoryItem')
          expect(update.record_id).to eq(original_id)
          expect(update.before).to eq('1st history item')
          expect(update.after).to eq(nil)
          expect(family.history_items.count).to eq(0)
        end
      end

      describe "Reference sections" do
        it "should replace existing items when the count is the same, and not convert incoming taxt" do
          reference_sections = [
            {title_taxt: @ants_title_taxt, subtitle_taxt: @ants_subtitle_taxt, references_taxt: @ants_references_taxt},
          ]

          @family.import_reference_sections reference_sections

          expect(Update.count).to eq(3)

          update = Update.find_by_field_name 'title_taxt'
          expect(update.class_name).to eq('ReferenceSection')
          expect(update.record_id).to eq(@family.reference_sections.first.id)
          expect(update.before).to eq('References')
          expect(update.after).to eq(@ants_title_taxt)

          update = Update.find_by_field_name 'subtitle_taxt'
          expect(update.before).to eq('of New Guinea')
          expect(update.after).to eq(@ants_subtitle_taxt)

          expect(@family.reference_sections.count).to eq(1)
          expect(@family.reference_sections.first.title_taxt).to eq(@ants_title_taxt)
        end

        it "should append new items" do
          reference_sections = [
            {title_taxt: 'References', subtitle_taxt: 'of New Guinea', references_taxt: 'References go here'},
            {title_taxt: '2nd reference section', subtitle_taxt: '2nd subtitle', references_taxt: '2nd references'},
          ]

          @family.import_reference_sections reference_sections

          expect(Update.count).to eq(3)

          update = Update.find_by_field_name 'title_taxt'
          expect(update.class_name).to eq('ReferenceSection')
          expect(update.record_id).to eq(@family.reference_sections.second.id)
          expect(update.before).to eq(nil)
          expect(update.after).to eq('2nd reference section')
          expect(@family.reference_sections.count).to eq(2)
          expect(@family.reference_sections.first.title_taxt).to eq('References')
          expect(@family.reference_sections.second.title_taxt).to eq('2nd reference section')
        end
        it "should delete deleted ones" do
          reference_sections = []
          original_id = @family.reference_sections.first.id

          @family.import_reference_sections reference_sections

          expect(Update.count).to eq(1)

          update = Update.find_by_class_name_and_record_id 'ReferenceSection', original_id
          expect(update.field_name).to be_nil
          expect(update.before).to be_nil
          expect(update.after).to be_nil
          expect(@family.reference_sections.count).to eq(0)
        end
      end

      describe "Protonym" do
        pending "importers, not germane to core functionality"

        it "should handle value fields" do
          data = @data.dup
          data[:protonym][:sic] = true
          data[:protonym][:fossil] = true
          data[:protonym][:locality] = 'U.S.A.'

          family = Family.import data

          expect(Update.count).to eq(3)

          update = Update.find_by_field_name 'sic'
          expect(update.class_name).to eq('Protonym')
          expect(update.record_id).to eq(@protonym.id)
          expect(update.before).to eq('0')
          expect(update.after).to eq('1')
          expect(family.protonym.sic).to be_truthy

          update = Update.find_by_field_name 'fossil'
          expect(update.class_name).to eq('Protonym')
          expect(update.record_id).to eq(@protonym.id)
          expect(update.before).to eq('0')
          expect(update.after).to eq('1')
          expect(family.protonym.fossil).to be_truthy

          update = Update.find_by_field_name 'locality'
          expect(update.class_name).to eq('Protonym')
          expect(update.record_id).to eq(@protonym.id)
          expect(update.before).to eq('CANADA')
          expect(update.after).to eq('U.S.A.')
          expect(family.protonym.locality).to be_truthy

        end

        it "should compare, record and update its name" do
          data = @data.dup
          data[:protonym][:family_or_subfamily_name] = 'Formicadiae'

          family = Family.import data

          expect(Update.count).to eq(1)

          update = Update.find_by_field_name 'name'
          expect(update.before).to eq('Formicariae')
          expect(update.after).to eq('Formicadiae')
          expect(family.protonym.name.name).to eq('Formicadiae')
        end

      end

      describe "Citation" do
        it "should record changes in notes_taxt" do
          data = @data.dup
          data[:protonym][:authorship][0][:notes] = [[{genus_name: 'Atta'}]]
          family = Family.import data
          update = Update.find_by_field_name 'notes_taxt'
          expect(update.class_name).to eq('Citation')
          expect(update.before).to eq(nil)
          expect(update.after).to eq(" (#{@nam_taxt})")
          expect(family.protonym.authorship.notes_taxt).to eq(" (#{@nam_taxt})")
        end
        it "should record changes in value fields" do
          data = @data.dup
          citation = data[:protonym][:authorship][0]
          citation[:forms] = 'q.'
          citation[:pages] = '100'

          family = Family.import data

          expect(Update.count).to eq(2)

          update = Update.find_by_field_name 'pages'
          expect(update.class_name).to eq('Citation')
          expect(update.before).to eq('12')
          expect(update.after).to eq('100')
          expect(family.protonym.authorship.pages).to eq('100')

          update = Update.find_by_field_name 'forms'
          expect(update.before).to eq('w.')
          expect(update.after).to eq('q.')
          expect(family.protonym.authorship.forms).to eq('q.')
        end
        it "should record a different reference than before" do
          new_reference = FactoryGirl.create :article_reference,
            author_names: [FactoryGirl.create(:author_name, name: 'Bolton')], citation_year: '2005', bolton_key_cache: 'Bolton 2005'
          data = @data.dup
          data[:protonym][:authorship].first[:author_names] = ['Bolton, B.']
          data[:protonym][:authorship].first[:year] = '2005'

          family = Family.import data

          expect(Update.count).to eq(1)

          update = Update.find_by_field_name 'reference'
          expect(update.class_name).to eq('Citation')
          expect(update.before).to eq('Latreille, 1809')
          expect(update.after).to eq('Bolton, 2005')
          expect(family.protonym.authorship.reference.principal_author_last_name).to eq('Bolton')
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
      expect(family.statistics).to eq({
        :extant => {subfamilies: {'valid' => 1}, tribes: {'valid' => 1}, genera: {'valid' => 1, 'homonym' => 1}},
        :fossil => {subfamilies: {'valid' => 2}}
      })
    end
  end

  describe "Label" do
    it "should be the family name" do
      expect(FactoryGirl.create(:family, name: FactoryGirl.create(:name, name: 'Formicidae')).name.to_html).to eq('Formicidae')
    end
  end

  describe "Genera" do
    it "should include genera without subfamilies" do
      family = create_family
      subfamily = create_subfamily
      genus_without_subfamily = create_genus subfamily: nil
      genus_with_subfamily = create_genus subfamily: subfamily
      expect(family.genera).to eq([genus_without_subfamily])
    end
  end

  describe "Subfamilies" do
    it "should include all the subfamilies" do
      family = create_family
      subfamily = create_subfamily
      expect(family.subfamilies).to eq([subfamily])
    end
  end

end
