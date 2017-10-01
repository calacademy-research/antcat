require "spec_helper"

describe TaxonDecorator::TaxonStatus do
  describe "#call" do
    it "returns 'valid' if the status is valid" do
      taxon = create_genus
      expect(taxon.decorate.taxon_status).to eq 'valid'
    end

    it "shows the status if there is one" do
      taxon = create_genus status: 'homonym'
      expect(taxon.decorate.taxon_status).to eq 'homonym'
    end

    it "is html_safe" do
      expect(create_genus.decorate.taxon_status).to be_html_safe
    end

    it "shows one synonym" do
      senior_synonym = create_genus 'Atta'
      junior_synonym = create_genus 'Atta', status: 'synonym'
      create_synonym junior_synonym, senior_synonym

      expect(junior_synonym.decorate.taxon_status)
        .to eq %{junior synonym of current valid taxon <a href="/catalog/#{senior_synonym.id}"><i>Atta</i></a>}
    end

    describe "Using current valid taxon" do
      context "when a null current valid taxon" do
        let!(:senior_synonym) { create_genus 'Atta' }
        let!(:other_senior_synonym) { create_genus 'Eciton' }
        let!(:junior_synonym) { create :genus, :synonym }

        before { create_synonym junior_synonym, senior_synonym }

        before do
          senior_synonym.update_attribute :created_at, Time.now - 100
          Synonym.create! senior_synonym: other_senior_synonym, junior_synonym: junior_synonym
        end

        specify do
          expect(junior_synonym.decorate.taxon_status)
            .to eq %{junior synonym of current valid taxon <a href="/catalog/#{other_senior_synonym.id}"><i>Eciton</i></a>}
        end
      end

      context "when a null current valid taxon with no synonyms" do
        let!(:taxon) { create_genus status: 'synonym' }

        specify do
          expect(taxon.decorate.taxon_status).to eq "junior synonym"
        end
      end

      context "when a current valid taxon that's one of two 'senior synonyms'" do
        let!(:senior_synonym) { create_genus 'Atta' }
        let!(:other_senior_synonym) { create_genus 'Eciton' }
        let!(:junior_synonym) { create :genus, status: 'synonym', current_valid_taxon: other_senior_synonym }

        before { create_synonym junior_synonym, senior_synonym }

        before do
          senior_synonym.update_attribute :created_at, Time.now - 100
          Synonym.create! senior_synonym: other_senior_synonym, junior_synonym: junior_synonym
        end

        it specify do
          expect(junior_synonym.decorate.taxon_status)
            .to eq %{junior synonym of current valid taxon <a href="/catalog/#{other_senior_synonym.id}"><i>Eciton</i></a>}
        end
      end
    end

    context "when unresolved homonym" do
      let(:taxon) { create_genus 'Atta' }

      before { taxon.update! unresolved_homonym: true }

      context "when there is no senior synonym" do
        specify { expect(taxon.decorate.taxon_status).to eq 'unresolved junior homonym' }
      end

      context "when there is a current valid taxon" do
        let!(:senior_synonym) { create_genus 'Eciton' }

        before { taxon.update! current_valid_taxon: senior_synonym }

        specify do
          expect(taxon.decorate.taxon_status)
            .to eq %{unresolved junior homonym, junior synonym of current valid taxon <a href="/catalog/#{senior_synonym.id}"><i>Eciton</i></a>}
        end
      end
    end

    context "if the senior synonym hasn't been set yet" do
      let!(:taxon) { create_genus status: 'synonym' }

      it "doesn't freak out if the senior synonym hasn't been set yet" do
        expect(taxon.decorate.taxon_status).to eq 'junior synonym'
      end
    end

    context "when incertae sedis" do
      let(:taxon) { create_genus incertae_sedis_in: 'family' }

      specify do
        expect(taxon.decorate.taxon_status).to eq '<i>incertae sedis</i> in family, valid'
      end
    end
  end

  describe "#format_senior_synonym" do
    context "when the senior synonym is itself invalid" do
      let(:invalid_senior) { create_genus 'Atta', status: 'synonym' }
      let(:junior) { create_genus 'Eciton', status: 'synonym' }
      subject { described_class.new(junior) }

      before { Synonym.create! junior_synonym: junior, senior_synonym: invalid_senior }

      it "returns an empty string" do
        expect(subject.send(:format_senior_synonym)).to eq ''
      end
    end
  end
end
