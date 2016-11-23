require 'spec_helper'

describe Taxon do
  it { should validate_presence_of :name }
  it { should validate_presence_of :protonym }
end

describe "callbacks" do
  describe "#build_default_taxon_state and #set_taxon_state_to_waiting" do
    context "when creating a taxon" do
      let(:taxon) { build_minimal_family }

      it "creates a taxon_state" do
        expect(taxon.taxon_state).to be nil
        taxon.save
        expect(taxon.taxon_state).not_to be nil
      end

      it "sets the review_status to 'waiting'" do
        taxon.save
        expect(taxon).to be_waiting
      end
    end

    context "when updating" do
      let(:taxon) { an_old_taxon }

      it "tests tests and makes sure Workflow is in sync" do
        expect(taxon.taxon_state.review_state).to eq "old"
        expect(taxon).not_to be_waiting

        taxon.save_initiator = true
        taxon.save

        expect(taxon.taxon_state.review_state).to eq "waiting"
        expect(taxon).to be_waiting
      end

      context "it `save_initiator`" do
        it "sets the review_status to 'waiting'" do
          taxon.save_initiator = true
          taxon.save
          expect(taxon).to be_waiting
        end

        it "doesn't cascade" do
          family, subfamily = old_family_and_subfamily

          family.save_initiator = true
          family.save

          expect(family).to be_waiting
          expect(subfamily).not_to be_waiting
        end
      end

      context "it not `save_initiator`" do
        it "doesn't change the review state" do
          expect(taxon).to be_old
          taxon.save
          expect(taxon).to be_old
        end
      end
    end
  end

  describe "#remove_auto_generated" do
    context "a generated taxon" do
      it "removes 'auto_generated' flags from things" do
        # Setup.
        taxon = minimal_family
        another_taxon = minimal_family
        synonym = Synonym.create! senior_synonym: taxon, junior_synonym: another_taxon

        actors = [taxon, taxon.name, synonym]

        mark_as_auto_generated actors
        actors.each &:reload

        # Act and test.
        taxon.save_initiator = true
        taxon.save
        actors.each &:reload

        actors.each { |object| expect(object).to_not be_auto_generated }
      end

      it "doesn't cascade" do
        # Setup.
        family, subfamily = old_family_and_subfamily

        actors = [family, subfamily, family.name, subfamily.name]
        mark_as_auto_generated actors
        actors.each &:reload

        # Act and test.
        family.save_initiator = true
        family.save
        actors.each &:reload

        expect(family).to_not be_auto_generated
        expect(family.name).to_not be_auto_generated
        expect(subfamily).to be_auto_generated
        expect(subfamily.name).to be_auto_generated
      end
    end
  end

  # TODO improve "expect_any_instance_of" etc.
  describe "#save_children" do
    let!(:species) { create :species }
    let!(:genus) { Taxon.find species.genus.id }
    let!(:tribe) { Taxon.find genus.tribe.id }
    let!(:subfamily) { Taxon.find species.subfamily.id }

    context "taxon is not the `save_initiator`" do
      it "doesn't save the children" do
        # The `save_initiator` should be saved.
        expect(subfamily).to receive(:save).and_call_original
        expect_any_instance_of(Subfamily).to_not receive(:save_children).and_call_original

        # But not its children.
        [Tribe, Genus, Species].each do |klass|
          expect_any_instance_of(klass).to_not receive(:save_children).and_call_original
          expect_any_instance_of(klass).to_not receive(:save).and_call_original
        end

        subfamily.save
      end
    end

    context "taxon is the `save_initiator`" do
      it "saves the children" do
        # All children should be saved, and their children too.
        [Subfamily, Tribe, Genus, Species].each do |klass|
          expect_any_instance_of(klass).to receive(:save_children).and_call_original
          expect_any_instance_of(klass).to receive(:save).and_call_original
        end

        # But not the family.
        expect_any_instance_of(Family).to_not receive(:save_children).and_call_original

        subfamily.save_initiator = true
        subfamily.save
      end

      it "doesn't save unrelated taxa" do
        another_subfamily = minimal_subfamily

        expect(another_subfamily).to receive(:save).and_call_original
        expect(subfamily).to_not receive(:save).and_call_original

        [Tribe, Genus, Species].each do |klass|
          expect_any_instance_of(klass).to_not receive(:save_children).and_call_original
          expect_any_instance_of(klass).to_not receive(:save).and_call_original
        end

        another_subfamily.save_initiator = true
        another_subfamily.save
      end

      it "never recursively saves children of families" do
        family = minimal_family

        family.save_initiator = true
        expect(family.save_children).to be nil

        # Confirm test isn't borked.
        subfamily.save_initiator = true
        expect(subfamily.save_children).to_not be nil
      end
    end
  end

  describe "#set_name_caches" do
    # TODO
  end

  describe "#delete_synonyms" do
    let(:senior) { create_genus 'Atta' }
    let(:junior) { create_genus 'Eciton', status: "synonym" }
    before { Synonym.create! junior_synonym: junior, senior_synonym: senior }

    it "*confirm test setup*" do
      expect(junior.status).to eq "synonym"
      expect(senior.junior_synonyms.count).to eq 1
      expect(junior.senior_synonyms.count).to eq 1
    end

    describe "saving a taxon" do
      context "with the status 'synonym'" do
        context "status was not changed" do
          it "doesn't destroy any synonyms" do
            junior.fossil = true

            expect { junior.save! }.to_not change { Synonym.count }
            expect(senior.junior_synonyms.count).to eq 1
            expect(junior.senior_synonyms.count).to eq 1
          end
        end

        context "status was changed from 'synonym'" do
          it "destroys all synonyms where it's the junior" do
            junior.status = "valid"

            expect { junior.save! }.to change { Synonym.count }.by -1
            expect(senior.junior_synonyms.count).to eq 0
            expect(junior.senior_synonyms.count).to eq 0
          end
        end
      end

      context "that doesn't have the status 'synonym'" do
        context "status was changed" do
          it "doesn't destroy any synonyms" do
            senior.status = "homonym"

            expect { senior.save! }.to_not change { Synonym.count }
            expect(senior.junior_synonyms.count).to eq 1
            expect(junior.senior_synonyms.count).to eq 1
          end
        end
      end
    end
  end
end
