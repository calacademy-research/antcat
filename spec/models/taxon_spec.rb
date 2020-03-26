# frozen_string_literal: true

require 'rails_helper'

describe Taxon do
  describe 'relations' do
    subject(:taxon) { create :family }

    it { is_expected.to have_many(:history_items).dependent(:destroy) }
    it { is_expected.to have_many(:reference_sections).dependent(:destroy) }
    it { is_expected.to belong_to(:protonym).dependent(false) }
    it { is_expected.to belong_to(:name).dependent(:destroy) }
  end

  describe 'validations' do
    subject(:taxon) { create :family }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :protonym }
    it { is_expected.to validate_inclusion_of(:status).in_array(Status::STATUSES) }

    describe "#homonym_replaced_by" do
      context 'when taxon is a homonym' do
        let(:replaced_by) { build_stubbed :family }
        let(:taxon) { build_stubbed :family, :homonym, homonym_replaced_by: replaced_by }

        it 'must have a `homonym_replaced_by`' do
          expect { taxon.homonym_replaced_by = nil }.to change { taxon.valid? }.to false
          expect(taxon.errors.messages).to include(homonym_replaced_by: ["must be set for homonyms"])
        end
      end

      context 'when taxon is not a homonym' do
        let(:taxon) { build_stubbed :family }
        let(:replaced_by) { build_stubbed :family }

        it 'cannot have a `homonym_replaced_by`' do
          expect { taxon.homonym_replaced_by = replaced_by }.to change { taxon.valid? }.to false
          expect(taxon.errors.messages).to include(homonym_replaced_by: ["can't be set for non-homonyms"])
        end
      end
    end

    describe "#unresolved_homonym" do
      context 'when taxon is a homonym' do
        let(:taxon) { build_stubbed :family, unresolved_homonym: true }

        it 'cannot be an `unresolved_homonym`' do
          expect { taxon.status = Status::HOMONYM }.to change { taxon.valid? }.to false
          expect(taxon.errors.messages).to include(unresolved_homonym: ["can't be set for homonyms"])
        end
      end
    end

    describe "#original_combination" do
      context 'when taxon is not in `CAN_BE_A_COMBINATION_TYPES`' do
        let(:taxon) { build_stubbed :family }

        it 'cannot be an `original_combination`' do
          expect { taxon.original_combination = true }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(original_combination: ["can not be set for taxa of this rank"])
        end
      end

      context 'when taxon rank is in `CAN_BE_A_COMBINATION_TYPES`' do
        let(:taxon) { build_stubbed :species }

        it 'may be an `original_combination`' do
          expect { taxon.original_combination = true }.to_not change { taxon.valid? }.from(true)
        end
      end
    end

    describe "#nomen_nudum" do
      context 'when taxon is not unavailable' do
        let(:taxon) { build_stubbed :family }

        it 'cannot be a `nomen_nudum`' do
          expect { taxon.nomen_nudum = true }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(nomen_nudum: ["can only be set for unavailable taxa"])
        end
      end

      context 'when taxon is unavailable' do
        let(:taxon) { build_stubbed :family, :unavailable }

        it 'may be a `nomen_nudum`' do
          expect { taxon.nomen_nudum = true }.to_not change { taxon.valid? }.from(true)
        end
      end
    end

    describe "#ichnotaxon" do
      context 'when taxon is not fossil' do
        let(:taxon) { build_stubbed :family }

        it 'cannot be a `ichnotaxon`' do
          expect { taxon.ichnotaxon = true }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(ichnotaxon: ["can only be set for fossil taxa"])
        end
      end

      context 'when taxon is fossil' do
        let(:taxon) { build_stubbed :family, :fossil }

        it 'may be a `ichnotaxon`' do
          expect { taxon.ichnotaxon = true }.to_not change { taxon.valid? }.from(true)
        end
      end
    end

    describe "#collective_group_name" do
      context 'when taxon is not fossil' do
        let(:taxon) { build_stubbed :family }

        it 'cannot be a `collective_group_name`' do
          expect { taxon.collective_group_name = true }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(collective_group_name: ["can only be set for fossil taxa"])
        end
      end

      context 'when taxon is fossil' do
        let(:taxon) { build_stubbed :family, :fossil }

        it 'may be a `collective_group_name`' do
          expect { taxon.collective_group_name = true }.to_not change { taxon.valid? }.from(true)
        end
      end
    end

    describe "#type_taxt" do
      context 'when taxon does not have a type taxon' do
        let(:taxon) { build_stubbed :family }

        it 'cannot have a `type_taxt`' do
          expect { taxon.type_taxt = 'by monotypy' }.to change { taxon.valid? }.to(false)
          expect(taxon.errors.messages).to include(type_taxt: ["(type notes) can't be set unless taxon has a type name"])
        end
      end

      context 'when taxon has a type taxon' do
        let(:taxon) { build_stubbed :family, type_taxon: create(:family) }

        it 'may have a `type_taxt`' do
          expect { taxon.type_taxt = 'by monotypy' }.to_not change { taxon.valid? }.from(true)
        end
      end
    end

    describe "#current_valid_taxon_validation" do
      [
        Status::VALID,
        Status::UNIDENTIFIABLE,
        Status::UNAVAILABLE,
        Status::EXCLUDED_FROM_FORMICIDAE,
        Status::HOMONYM
      ].each do |status|
        context "when status is #{status}" do
          let(:taxon) { build :family, status: status, current_valid_taxon: create(:family) }

          it 'cannot have a `current_valid_taxon`' do
            taxon.valid?
            expect(taxon.errors.messages).to include(current_valid_name: ["can't be set for #{Status.plural(status)} taxa"])
          end
        end
      end

      [
        Status::SYNONYM,
        Status::OBSOLETE_COMBINATION,
        Status::UNAVAILABLE_MISSPELLING,
        Status::UNAVAILABLE_UNCATEGORIZED
      ].each do |status|
        context "when status is #{status}" do
          let(:taxon) { build :family, status: status }

          it 'must have a `current_valid_taxon`' do
            taxon.valid?
            expect(taxon.errors.messages).to include(current_valid_name: ["must be set for #{Status.plural(status)}"])
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

  it_behaves_like "a taxt column with cleanup", :headline_notes_taxt do
    subject { create :family }
  end

  it_behaves_like "a taxt column with cleanup", :type_taxt do
    subject { build :family }
  end

  describe "#rank" do
    let!(:taxon) { build_stubbed :subfamily }

    it "returns a lowercase version" do
      expect(taxon.rank).to eq 'subfamily'
    end
  end

  describe "#link_to_taxon" do
    let!(:taxon) { build_stubbed :subfamily }

    specify do
      expect(taxon.link_to_taxon).to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>)
    end
  end

  describe "#author_citation" do
    let!(:reference) { create :reference, author_name: 'Bolton', citation_year: '2005' }

    before do
      taxon.protonym.update!(name: protonym_name)
      taxon.protonym.authorship.update!(reference: reference)
    end

    context "when a recombination in a different genus" do
      let(:taxon) { create :species, name_string: 'Atta minor' }
      let(:protonym_name) { create :species_name, name: 'Eciton minor' }

      it "surrounds it in parentheses" do
        expect(taxon.author_citation).to eq '(Bolton, 2005)'
      end

      specify { expect(taxon.author_citation.html_safe?).to eq true }
    end

    context "when the name simply differs" do
      let(:taxon) { create :species, name_string: 'Atta minor maxus' }
      let(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "doesn't surround in parentheses" do
        expect(taxon.author_citation).to eq 'Bolton, 2005'
      end
    end
  end
end
