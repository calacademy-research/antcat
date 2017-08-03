require "spec_helper"

describe TaxonDecorator::Header do
  let(:decorator_helper) { TaxonDecorator::Header }

  describe "#link_each_epithet" do
    it "formats a subspecies with > 3 epithets" do
      formica = create_genus 'Formica'
      rufa = create_species 'rufa', genus: formica
      major_name = Name.create! name: 'Formica rufa pratensis major',
        epithet_html: '<i>major</i>',
        epithets: 'rufa pratensis major'
      major = create_subspecies name: major_name, species: rufa, genus: rufa.genus

      expect(decorator_helper.new(major).send(:link_each_epithet)).to eq(
        %{<a href="/catalog/#{formica.id}"><i>Formica</i></a> } +
        %{<a href="/catalog/#{rufa.id}"><i>rufa</i></a> } +
        %{<a href="/catalog/#{major.id}"><i>pratensis major</i></a>}
      )
    end
  end
end
