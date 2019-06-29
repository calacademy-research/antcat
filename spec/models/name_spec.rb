require 'spec_helper'

describe Name do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :epithet }

  describe 'relations' do
    it { is_expected.to have_many(:protonyms).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:taxa).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    describe '#ensure_starts_with_upper_case_letter' do
      let(:name) { build_stubbed :genus_name, name: 'lasius' }

      specify do
        expect(name.valid?).to eq false
        expect(name.errors[:name]).to eq ["must start with a capital letter"]
      end
    end
  end

  describe '`set_epithet` and `#set_epithets`' do
    let!(:name) { create :subspecies_name, name: 'Lasius niger fusca' }

    before do
      name.update_columns(epithet: 'pizza', epithets: 'pescatore')
    end

    specify { expect { name.save }.to change { name.epithet }.from('pizza').to('fusca') }
    specify { expect { name.save }.to change { name.epithets }.from('pescatore').to('niger fusca') }
  end

  describe "#epithet_with_fossil_html" do
    it "formats the fossil symbol" do
      expect(SpeciesName.new(epithet: 'major').epithet_with_fossil_html(true)).to eq '<i>&dagger;</i><i>major</i>'
      expect(SpeciesName.new(epithet: 'major').epithet_with_fossil_html(false)).to eq '<i>major</i>'
      expect(GenusName.new(epithet: 'Atta').epithet_with_fossil_html(true)).to eq '<i>&dagger;</i><i>Atta</i>'
      expect(GenusName.new(epithet: 'Atta').epithet_with_fossil_html(false)).to eq '<i>Atta</i>'
      expect(SubfamilyName.new(epithet: 'Attanae').epithet_with_fossil_html(true)).to eq '&dagger;Attanae'
      expect(SubfamilyName.new(epithet: 'Attanae').epithet_with_fossil_html(false)).to eq 'Attanae'
    end
  end

  describe "#name_with_fossil_html" do
    it "formats the fossil symbol" do
      expect(SpeciesName.new(name: 'Atta major').name_with_fossil_html(false)).to eq '<i>Atta major</i>'
      expect(SpeciesName.new(name: 'Atta major').name_with_fossil_html(true)).to eq '<i>&dagger;</i><i>Atta major</i>'
    end
  end

  describe "#set_taxon_caches" do
    let!(:atta_name) { create :genus_name, name: 'Atta' }

    context 'when name is assigned to a taxon' do
      let!(:taxon) { create :genus, name_string: 'Eciton' }

      it "sets the taxons's `name_cache` and `name_html_cache`" do
        expect(taxon.name_cache).to eq 'Eciton'
        expect(taxon.name_html_cache).to eq '<i>Eciton</i>'

        taxon.name = atta_name
        taxon.save!
        expect(taxon.name_cache).to eq 'Atta'
        expect(taxon.name_html_cache).to eq '<i>Atta</i>'
      end
    end

    context 'when the contents of the name change' do
      let!(:taxon) { create :genus, name: atta_name }

      it "changes the cache" do
        expect(taxon.name_cache).to eq 'Atta'
        expect(taxon.name_html_cache).to eq '<i>Atta</i>'
        atta_name.update! name: 'Betta'
        taxon.reload
        expect(taxon.name_cache).to eq 'Betta'
        expect(taxon.name_html_cache).to eq '<i>Betta</i>'
      end
    end

    context 'when a different name is assigned' do
      let!(:betta_name) { create :genus_name, name: 'Betta' }
      let!(:taxon) { create :genus, name: atta_name }

      it "changes the cache" do
        taxon.update! name: betta_name
        expect(taxon.name_cache).to eq 'Betta'
        expect(taxon.name_html_cache).to eq '<i>Betta</i>'
      end
    end
  end

  describe "#what_links_here" do
    let(:name) { described_class.new }

    it "calls `Names::WhatLinksHere`" do
      expect(Names::WhatLinksHere).to receive(:new).with(name).and_call_original
      name.what_links_here
    end
  end
end
