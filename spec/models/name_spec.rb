require 'spec_helper'

describe Name do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :epithet }

  describe 'epithet validation' do
    subject { build_stubbed :name, name: 'Lasius' }

    it { is_expected.to allow_value('Lasius').for :epithet }
    it { is_expected.not_to allow_value('Different').for :epithet }
  end

  describe 'relations' do
    it { is_expected.to have_many(:protonyms).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:taxa).dependent(:restrict_with_error) }
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
      let!(:taxon) { create_genus 'Eciton' }

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
        atta_name.update name: 'Betta', epithet: 'Betta'
        taxon.reload
        expect(taxon.name_cache).to eq 'Betta'
        expect(taxon.name_html_cache).to eq '<i>Betta</i>'
      end
    end

    context 'when a different name is assigned' do
      let!(:betta_name) { create :genus_name, name: 'Betta' }
      let!(:taxon) { create :genus, name: atta_name }

      it "changes the cache" do
        taxon.update name: betta_name
        expect(taxon.name_cache).to eq 'Betta'
        expect(taxon.name_html_cache).to eq '<i>Betta</i>'
      end
    end
  end

  describe "#what_links_here" do
    subject { described_class.new }

    it "calls `Names::WhatLinksHere`" do
      expect(Names::WhatLinksHere).to receive(:new).with(subject).and_call_original
      subject.what_links_here
    end
  end

  describe ".find_by_name" do
    let(:atta_name) { create :name, name: 'Atta' }
    let(:taxon) { create_genus 'Atta' }

    it "prioritizes names already associated with taxa" do
      expect(taxon.name).not_to eq atta_name
      expect(described_class.find_by_name('Atta')).to eq taxon.name
    end
  end
end
