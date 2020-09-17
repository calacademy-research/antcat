# frozen_string_literal: true

require 'rails_helper'

describe Taxon do
  include TestLinksHelpers

  it { is_expected.to be_versioned }

  describe 'relations' do
    subject(:taxon) { create :any_taxon }

    it { is_expected.to have_many(:history_items).dependent(:destroy) }
    it { is_expected.to have_many(:reference_sections).dependent(:destroy) }
    it { is_expected.to belong_to(:protonym).required.dependent(false) }
    it { is_expected.to belong_to(:name).required.dependent(:destroy) }

    describe 'required `belongs_to`' do
      subject(:taxon) { create :any_taxon }

      it { is_expected.to belong_to(:name).required }
      it { is_expected.to belong_to(:protonym).required }
    end
  end

  describe 'validations' do
    describe '#status' do
      subject(:taxon) { build_stubbed :any_taxon }

      it { is_expected.to validate_inclusion_of(:status).in_array(Status::STATUSES) }
    end

    describe "#homonym_replaced_by" do
      context 'when taxon is a homonym' do
        let(:taxon) { build_stubbed :any_taxon, :homonym }

        it 'must have a `homonym_replaced_by`' do
          expect { taxon.homonym_replaced_by = nil }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(homonym_replaced_by: ["must be set for homonyms"])
        end
      end

      context 'when taxon is not a homonym' do
        let(:taxon) { build_stubbed :any_taxon }

        it 'cannot have a `homonym_replaced_by`' do
          expect { taxon.homonym_replaced_by = build_stubbed(:any_taxon) }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(homonym_replaced_by: ["can't be set for non-homonyms"])
        end
      end
    end

    describe "#unresolved_homonym" do
      context 'when taxon is a homonym' do
        let(:taxon) { build_stubbed :any_taxon, :unresolved_homonym }

        it 'cannot be an `unresolved_homonym`' do
          expect { taxon.status = Status::HOMONYM }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(unresolved_homonym: ["can't be set for homonyms"])
        end
      end
    end

    describe "#ichnotaxon" do
      context 'when taxon is not fossil' do
        let(:taxon) { build_stubbed :any_taxon }

        it 'cannot be a `ichnotaxon`' do
          expect { taxon.ichnotaxon = true }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(ichnotaxon: ["can only be set for fossil taxa"])
        end
      end
    end

    describe "#collective_group_name" do
      context 'when taxon is not fossil' do
        let(:taxon) { build_stubbed :any_taxon }

        it 'cannot be a `collective_group_name`' do
          expect { taxon.collective_group_name = true }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(collective_group_name: ["can only be set for fossil taxa"])
        end
      end
    end

    describe "#current_taxon_validation" do
      [
        Status::VALID,
        Status::UNIDENTIFIABLE,
        Status::UNAVAILABLE,
        Status::EXCLUDED_FROM_FORMICIDAE,
        Status::HOMONYM
      ].each do |status|
        context "when status is #{status}" do
          let(:taxon) { build :any_taxon, status: status, current_taxon: create(:any_taxon) }

          it 'cannot have a `current_taxon`' do
            taxon.valid?
            expect(taxon.errors.messages).to include(current_taxon: ["can't be set for #{Status.plural(status)} taxa"])
          end
        end
      end

      [
        Status::SYNONYM,
        Status::OBSOLETE_COMBINATION,
        Status::UNAVAILABLE_MISSPELLING
      ].each do |status|
        context "when status is #{status}" do
          let(:taxon) { build :any_taxon, status: status }

          it 'must have a `current_taxon`' do
            taxon.valid?
            expect(taxon.errors.messages).to include(current_taxon: ["must be set for #{Status.plural(status)}"])
          end
        end
      end
    end

    describe "#ensure_correct_name_type" do
      context 'when `Taxon` and `Name` classes do not match' do
        context 'when taxon is created' do
          let(:genus_name) { create :genus_name }
          let(:family) { build_stubbed :family, name: genus_name }

          specify do
            expect(family.valid?).to eq false
            expect(family.errors.messages[:base].first).to include 'and name type (`GenusName`) must match'
          end
        end

        context 'when taxon is updated' do
          let(:family) { create :family }
          let(:genus_name) { create :genus_name }

          specify do
            expect { family.name = genus_name }.to change { family.valid? }.from(true).to(false)
            expect(family.errors.messages[:base].first).to include 'and name type (`GenusName`) must match'
          end
        end
      end
    end
  end

  describe 'callbacks' do
    subject(:taxon) { build_stubbed :any_taxon }

    it { is_expected.to strip_attributes(:incertae_sedis_in) }
  end

  describe "#rank" do
    let!(:taxon) { build_stubbed :subfamily }

    it "returns a lowercase version" do
      expect(taxon.rank).to eq 'subfamily'
    end
  end

  describe "#author_citation" do
    let!(:reference) { create :any_reference, author_string: 'Bolton', year: 2005 }

    before do
      taxon.protonym.update!(name: protonym_name)
      taxon.protonym.authorship.update!(reference: reference)
    end

    context "when taxon is a recombination" do
      let(:taxon) { create :species, name_string: 'Atta minor' }
      let(:protonym_name) { create :species_name, name: 'Eciton minor' }

      it "surrounds the author citation in parentheses" do
        expect(taxon.author_citation).to eq '(Bolton, 2005)'
      end

      specify { expect(taxon.author_citation.html_safe?).to eq true }
    end

    context "when taxon is not a recombination" do
      let(:taxon) { create :subspecies, name_string: 'Atta minor maxus' }
      let(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "doesn't surround the author citation in parentheses" do
        expect(taxon.author_citation).to eq 'Bolton, 2005'
      end
    end
  end
end
