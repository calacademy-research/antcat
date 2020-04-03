# frozen_string_literal: true

require 'rails_helper'

describe Reference do
  it { is_expected.to be_versioned }
  it { is_expected.to delegate_method(:routed_url).to(:document).allow_nil }
  it { is_expected.to delegate_method(:downloadable?).to(:document).allow_nil }

  describe 'relations' do
    it { is_expected.to have_many(:reference_author_names).dependent(:destroy) }
    it { is_expected.to have_many(:citations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:nestees).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:document).dependent(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :author_names }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to_not allow_values('<', '>').for(:doi) }

    describe '`bolton_key` uniqueness' do
      let!(:conflict) { create :any_reference, bolton_key: 'Batiatus 2000' }
      let!(:duplicate) { create :any_reference }

      specify do
        expect { duplicate.bolton_key = conflict.bolton_key }.
          to change { duplicate.valid? }.from(true).to(false)
        expect(duplicate.errors[:bolton_key].first).to include "Bolton key has already been taken by"
        expect(duplicate.errors[:bolton_key].first).to include conflict.keey
      end
    end
  end

  describe 'callbacks' do
    describe "changing `citation_year`" do
      context 'when `citation_year` contains a letter' do
        let(:reference) { create :any_reference, citation_year: '1910a' }

        it "sets `year` to the stated year, if present" do
          expect { reference.update!(citation_year: '2010b') }.
            to change { reference.reload.year }.from(1910).to(2010)
        end
      end

      context 'when `citation_year` contains a bracketed year' do
        let(:reference) { create :any_reference, citation_year: '1910a ["1958"]' }

        it "sets `year` to the stated year, if present" do
          expect { reference.update!(citation_year: '2010b ["2009"]') }.
            to change { reference.reload.year }.from(1958).to(2009)
        end
      end
    end
  end

  describe "scopes" do
    describe ".unreviewed_references" do
      let!(:unreviewed) { create :any_reference, review_state: "reviewing" }

      before { create :any_reference, review_state: "reviewed" }

      it "returns unreviewed references" do
        expect(described_class.unreviewed).to eq [unreviewed]
      end
    end

    describe ".order_by_author_names_and_year" do
      it "sorts by author_name plus year plus letter" do
        one = create :any_reference, author_string: 'Fisher', citation_year: '1910b'
        two = create :any_reference, author_string: 'Wheeler', citation_year: '1874'
        three = create :any_reference, author_string: 'Fisher', citation_year: '1910a'

        expect(described_class.order_by_author_names_and_year).to eq [three, one, two]
      end
    end
  end

  describe 'workflow' do
    let(:reference) { create :any_reference }

    describe 'default state' do
      it "starts as 'none'" do
        expect(reference.none?).to eq true
        expect(reference.reviewing?).to eq false
        expect(reference.reviewed?).to eq false

        expect(reference.can_start_reviewing?).to eq true
        expect(reference.can_finish_reviewing?).to eq false
        expect(reference.can_restart_reviewing?).to eq false
      end
    end

    describe '#start_reviewing!' do
      it "none transitions to start" do
        expect { reference.start_reviewing! }.to change { reference.reviewing? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq true
        expect(reference.can_restart_reviewing?).to eq false
      end
    end

    describe '#finish_reviewing!' do
      before do
        reference.start_reviewing!
      end

      it "start transitions to finish" do
        expect { reference.finish_reviewing! }.to change { reference.reviewed? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq false
        expect(reference.can_restart_reviewing?).to eq true
      end
    end

    describe '#restart_reviewing!' do
      before do
        reference.start_reviewing!
        reference.finish_reviewing!
      end

      it "reviewed can transition back to reviewing" do
        expect { reference.restart_reviewing! }.to change { reference.reviewing? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq true
        expect(reference.can_restart_reviewing?).to eq false
      end
    end
  end

  describe "#author_names_string" do
    let(:ward) { create :author_name, name: 'Ward, P.S.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.L.' }

    describe "formatting" do
      it "consists of one author_name if that's all there is" do
        reference = build_stubbed :any_reference, author_names: [fisher]
        expect(reference.author_names_string).to eq 'Fisher, B.L.'
      end

      it "separates multiple author_names with semicolons" do
        reference = build_stubbed :any_reference, author_names: [fisher, ward]
        expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
      end
    end

    describe "updating, when things change" do
      let(:reference) { create :any_reference, author_names: [fisher] }

      context "when an author_name is added" do
        before { reference.author_names << ward }

        it "updates its `author_names_string`" do
          expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
        end
      end

      context "when an author_name is removed" do
        before { reference.author_names << ward }

        it "updates its `author_names_string`" do
          expect { reference.author_names.delete ward }.
            to change { reference.reload.author_names_string }.
            from('Fisher, B.L.; Ward, P.S.').to('Fisher, B.L.')
        end
      end

      context "when an author_name's name is changed" do
        before { reference.author_names = [ward] }

        it "updates its `author_names_string`" do
          expect { ward.update!(name: 'Fisher') }.
            to change { reference.reload.author_names_string }.
            from('Ward, P.S.').to('Fisher')
        end
      end
    end

    it "maintains the order in which they were added to the reference" do
      reference = create :any_reference, author_names: [ward]
      fisher = create :author_name, name: 'Fisher'
      wilden = create :author_name, name: 'Wilden'
      reference.author_names << wilden
      reference.author_names << fisher

      expect(reference.author_names_string).to eq 'Ward, P.S.; Wilden; Fisher'
    end
  end

  describe "#author_names_string_with_suffix" do
    let(:ward) { create :author_name, name: 'Ward, P.S.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.L.' }

    describe "formatting" do
      it "consists of one author_name if that's all there is" do
        reference = build_stubbed :reference, author_names: [fisher]
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L.'
      end

      it "separates multiple author_names with semicolons" do
        reference = build_stubbed :reference, author_names: [fisher, ward]
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L.; Ward, P.S.'
      end

      it "includes the author_names' suffix" do
        reference = build_stubbed :reference, author_names: [fisher], author_names_suffix: '(ed.)'
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L. (ed.)'
      end
    end
  end

  describe "#keey" do
    let(:bolton) { create :author_name, name: 'Bolton, B.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.' }

    context "when citation years with extra" do
      let(:reference) do
        create :any_reference, author_names: [bolton], citation_year: '1970a ("1971")'
      end

      specify { expect(reference.keey).to eq 'Bolton, 1970a' }
    end

    context 'when no authors' do
      let(:reference) { create :any_reference, citation_year: '1970a' }

      specify do
        expect { reference.author_names = [] }.
          to change { reference.keey }.to('[no authors], 1970a')
      end
    end

    context 'when one author' do
      let(:reference) do
        create :any_reference, author_names: [bolton], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton, 1970a' }
    end

    context 'when two authors' do
      let(:reference) do
        create :any_reference, author_names: [bolton, fisher], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton & Fisher, 1970a' }
    end

    context 'when three authors' do
      let(:ward) { create :author_name, name: 'Ward, P.S.' }
      let(:reference) do
        create :any_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton <i>et al.</i>, 1970a' }
      specify { expect(reference.keey.html_safe?).to eq true }
    end
  end

  describe "#keey_without_letters_in_year" do
    let(:reference) { create :any_reference, author_string: 'Bolton', citation_year: '1885g' }

    it "doesn't include the year ordinal" do
      expect(reference.keey_without_letters_in_year).to eq 'Bolton, 1885'
    end
  end

  describe "#what_links_here" do
    let(:reference) { build_stubbed :any_reference }

    it "calls `References::WhatLinksHere`" do
      expect(References::WhatLinksHere).to receive(:new).
        with(reference, predicate: false).and_call_original
      reference.what_links_here
    end
  end
end
