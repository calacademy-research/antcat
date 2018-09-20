require "spec_helper"

describe TaxonDecorator::TaxonStatus do
  describe "#call" do
    it "is html_safe" do
      expect(create(:family).decorate.taxon_status).to be_html_safe
    end

    context "when taxon is valid" do
      it "returns 'valid' if the status is valid" do
        taxon = create :family
        expect(taxon.decorate.taxon_status).to eq 'valid'
      end
    end

    context "when taxon is a homonym" do
      context "when taxon does not have a `homonym_replaced_by`" do
        let!(:taxon) { create :family, :homonym }

        specify { expect(taxon.decorate.taxon_status).to eq 'homonym' }
      end

      context "when taxon has a `homonym_replaced_by`" do
        let!(:homonym_replaced_by) { create :family }
        let!(:taxon) do
          create :family, :homonym, homonym_replaced_by: homonym_replaced_by
        end

        specify do
          expect(taxon.decorate.taxon_status).
            to include %(homonym replaced by <a href="/catalog/#{homonym_replaced_by.id}">Formicidae</a>)
        end
      end
    end

    context "when taxon is unidentifiable" do
      let!(:taxon) { create :family, :unidentifiable }

      specify { expect(taxon.decorate.taxon_status).to eq "unidentifiable" }
    end

    # NOTE `unresolved_homonym`s usually have a status that is not `homonym`.
    context "when taxon is an unresolved homonym" do
      let(:taxon) { create :family }

      before { taxon.update! unresolved_homonym: true }

      context "when there is no senior synonym" do
        specify { expect(taxon.decorate.taxon_status).to eq 'unresolved junior homonym' }
      end

      context "when there is a current valid taxon" do
        let!(:senior) { create :genus }

        before { taxon.update! current_valid_taxon: senior, status: Status::SYNONYM }

        specify do
          expect(taxon.decorate.taxon_status).
            to include %(unresolved junior homonym, junior synonym of current valid taxon <a href="/catalog/#{senior.id}"><i>#{senior.name_cache}</i></a>)
        end
      end
    end

    context "when taxon is a nomen nudum" do
      let!(:taxon) { create :family, nomen_nudum: true }

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
            to include %(junior synonym of current valid taxon <a href="/catalog/#{senior.id}"><i>#{senior.name_cache}</i></a>)
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
              to include %(junior synonym of current valid taxon <a href="/catalog/#{other_senior.id}"><i>#{other_senior.name_cache}</i></a>)
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

          it specify do
            expect(junior.decorate.taxon_status).
              to include %(junior synonym of current valid taxon <a href="/catalog/#{other_senior.id}"><i>#{other_senior.name_cache}</i></a>)
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
      let!(:taxon) { create :family, :excluded_from_formicidae }

      specify { expect(taxon.decorate.taxon_status).to eq "excluded from Formicidae" }
    end

    context "when taxon is incertae sedis" do
      let(:taxon) { create :genus, incertae_sedis_in: 'family' }

      specify do
        expect(taxon.decorate.taxon_status).to eq '<i>incertae sedis</i> in family, valid'
      end
    end
  end

  describe "#format_senior_synonym" do
    context "when the senior synonym is itself invalid" do
      subject { described_class.new(junior) }

      let(:invalid_senior) { create :family, :homonym }
      let(:junior) { create :family, :homonym }

      before { create :synonym, junior_synonym: junior, senior_synonym: invalid_senior }

      it "returns an empty string" do
        expect(subject.send(:format_senior_synonym)).to eq ''
      end
    end
  end
end
