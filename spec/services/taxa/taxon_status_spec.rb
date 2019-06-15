require "spec_helper"

describe Taxa::TaxonStatus do
  include TestLinksHelpers

  describe "#call" do
    it "is html_safe" do
      expect(build_stubbed(:family).decorate.taxon_status).to be_html_safe
    end

    context "when taxon is valid" do
      let(:taxon) { build_stubbed :family }

      it "returns 'valid' if the status is valid" do
        expect(taxon.decorate.taxon_status).to eq 'valid'
      end
    end

    context "when taxon is a homonym" do
      context "when taxon does not have a `homonym_replaced_by`" do
        let!(:taxon) { build_stubbed :family, :homonym }

        specify { expect(taxon.decorate.taxon_status).to eq 'homonym' }
      end

      context "when taxon has a `homonym_replaced_by`" do
        let!(:homonym_replaced_by) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :homonym, homonym_replaced_by: homonym_replaced_by }

        specify do
          expect(taxon.decorate.taxon_status).
            to include %(homonym replaced by #{taxon_link homonym_replaced_by})
        end
      end
    end

    context "when taxon is unidentifiable" do
      let!(:taxon) { build_stubbed :family, :unidentifiable }

      specify { expect(taxon.decorate.taxon_status).to eq "unidentifiable" }
    end

    context "when taxon is an unresolved homonym" do
      context "when there is no senior synonym" do
        let(:taxon) { build_stubbed :family, unresolved_homonym: true }

        specify { expect(taxon.decorate.taxon_status).to eq 'unresolved junior homonym' }
      end

      context "when there is a current valid taxon" do
        let(:senior) { build_stubbed :genus }
        let(:taxon) { build_stubbed :family, :synonym, unresolved_homonym: true, current_valid_taxon: senior }

        specify do
          expect(taxon.decorate.taxon_status).
            to include %(unresolved junior homonym, junior synonym of current valid taxon #{taxon_link senior})
        end
      end
    end

    context "when taxon is a nomen nudum" do
      let!(:taxon) { build_stubbed :family, nomen_nudum: true }

      specify { expect(taxon.decorate.taxon_status).to eq "<i>nomen nudum</i>" }
    end

    context "when taxon is a synonym" do
      context "when a taxon has no `Synonym`s" do
        context "when taxon does not have a `current_valid_taxon`" do
          let!(:taxon) { create :family, :synonym }

          specify do
            expect(taxon.decorate.taxon_status).to include "junior synonym"
          end
        end
      end

      context "when taxon has a single valid senior `Synonym`" do
        specify do
          senior = create :genus
          junior = create :genus, :synonym
          create :synonym, junior_synonym: junior, senior_synonym: senior

          expect(junior.decorate.taxon_status).
            to include %(junior synonym of current valid taxon #{taxon_link senior})
        end
      end

      describe "using current valid taxon" do
        context "when a null current valid taxon" do
          let!(:other_senior) { create :genus }
          let!(:junior) { create :genus, :synonym }

          before do
            senior = create :genus
            senior.update_attribute :created_at, 100.seconds.ago
            create :synonym, junior_synonym: junior, senior_synonym: senior

            create :synonym, senior_synonym: other_senior, junior_synonym: junior
          end

          specify do
            expect(junior.decorate.taxon_status).
              to include %(junior synonym of current valid taxon #{taxon_link other_senior})
          end
        end

        context "when a current valid taxon that's one of two 'senior synonyms'" do
          let!(:other_senior) { create :genus }
          let!(:junior) { create :genus, :synonym, current_valid_taxon: other_senior }

          before do
            senior = create :genus
            senior.update_attribute :created_at, 100.seconds.ago
            create :synonym, junior_synonym: junior, senior_synonym: senior

            create :synonym, senior_synonym: other_senior, junior_synonym: junior
          end

          specify do
            expect(junior.decorate.taxon_status).
              to include %(junior synonym of current valid taxon #{taxon_link other_senior})
          end
        end
      end
    end

    context "when taxon is an unavailable misspelling" do
      # TODO
    end

    context 'when taxon is "unavailable uncategorized"' do
      # TODO what to do?
    end

    context "when taxon is `invalid?`" do
      let!(:taxon) { build_stubbed :family, :excluded_from_formicidae }

      specify { expect(taxon.decorate.taxon_status).to eq "excluded from Formicidae" }
    end

    context "when taxon is incertae sedis" do
      let(:taxon) { build_stubbed :genus, incertae_sedis_in: 'family' }

      specify do
        expect(taxon.decorate.taxon_status).to eq '<i>incertae sedis</i> in family, valid'
      end
    end
  end
end
