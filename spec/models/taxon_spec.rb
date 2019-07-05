require 'spec_helper'

describe Taxon do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :protonym }
  it { is_expected.to validate_inclusion_of(:status).in_array(Status::STATUSES) }

  describe 'relations' do
    it { is_expected.to have_many(:history_items).dependent(:destroy) }
    it { is_expected.to have_many(:reference_sections).dependent(:destroy) }
    it { is_expected.to have_one(:homonym_replaced).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:protonym).dependent(false) }
    it { is_expected.to belong_to(:name).dependent(:destroy) }
  end

  describe "scopes" do
    describe ".self_join_on" do
      let!(:genus) { create :genus, fossil: true }
      let!(:species) { create :species, genus: genus }

      it "handles self-referential condition" do
        query = -> do
          described_class.self_join_on(:genus).
            where(fossil: false, taxa_self_join_alias: { fossil: true })
        end

        expect(query.call).to eq [species]
        genus.update fossil: false
        expect(query.call).to eq []
      end
    end
  end

  describe "workflow" do
    it "can transition from waiting to approved" do
      taxon = create :family
      create :change, taxon: taxon, change_type: "create"

      expect(taxon).to be_waiting
      expect(taxon.can_approve?).to be true

      taxon.approve!
      expect(taxon).to be_approved
      expect(taxon).not_to be_waiting
    end

    describe "#last_change" do
      let(:taxon) { create :family }

      it "returns nil if no changes have been created for it" do
        expect(taxon.last_change).to be_nil
      end

      it "returns the change, if any" do
        a_change = create :change, taxon: taxon
        create :version, item: taxon, change: a_change

        expect(taxon.last_change).to eq a_change
      end
    end
  end

  describe "#rank" do
    let!(:taxon) { build_stubbed :subfamily }

    it "returns a lowercase version" do
      expect(taxon.name.rank).to eq 'subfamily'
    end
  end

  describe "#link_to_taxon" do
    let!(:taxon) { build_stubbed :subfamily }

    specify do
      expect(taxon.link_to_taxon).to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>)
    end
  end

  describe "#author_citation" do
    context "when a recombination in a different genus" do
      let(:species) { create :species, name_string: 'Atta minor' }
      let(:protonym_name) { create :species_name, name: 'Eciton minor' }

      before do
        expect_any_instance_of(Reference).
          to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'
      end

      it "surrounds it in parentheses" do
        expect(species.author_citation).to eq '(Bolton, 2005)'
      end

      specify { expect(species.author_citation).to be_html_safe }
    end

    context "when the name simply differs" do
      let(:species) { create :species, name_string: 'Atta minor maxus' }
      let(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "doesn't surround in parentheses" do
        expect_any_instance_of(Reference).
          to receive(:keey_without_letters_in_year).and_return 'Bolton, 2005'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species.author_citation).to eq 'Bolton, 2005'
      end
    end
  end
end
