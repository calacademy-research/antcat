require "spec_helper"

describe TaxonDecorator::LinkEachEpithet do
  describe "#call" do
    context "subspecies with > 3 epithets" do
      let!(:formica) { create_genus 'Formica' }
      let!(:rufa) { create_species 'rufa', genus: formica }
      let!(:major) do
        major_name = Name.create! name: 'Formica rufa pratensis major',
          epithet_html: '<i>major</i>',
          epithets: 'rufa pratensis major'
        create_subspecies name: major_name, species: rufa, genus: rufa.genus
      end

      specify do
        expect(described_class[major]).to eq(
          %{<a href="/catalog/#{formica.id}"><i>Formica</i></a> } +
          %{<a href="/catalog/#{rufa.id}"><i>rufa</i></a> } +
          %{<a href="/catalog/#{major.id}"><i>pratensis major</i></a>}
        )
      end
    end
  end
end
