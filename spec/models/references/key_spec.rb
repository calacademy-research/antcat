# frozen_string_literal: true

require 'rails_helper'

describe References::Key do
  subject(:key) { described_class.new(reference) }

  describe "#key_with_suffixed_year" do
    context 'when no authors' do
      let(:reference) { create :any_reference, :with_author_name, year: 1970, year_suffix: 'a' }

      specify do
        expect { reference.author_names = [] }.to change { key.key_with_suffixed_year }.to('[no authors], 1970a')
      end
    end

    context 'when one author' do
      let(:reference) { create :any_reference, author_string: 'Bolton, B.', year: 1970, year_suffix: 'a' }

      specify { expect(key.key_with_suffixed_year).to eq 'Bolton, 1970a' }
    end

    context 'when two authors' do
      let(:reference) { create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.'], year: 1970, year_suffix: 'a' }

      specify { expect(key.key_with_suffixed_year).to eq 'Bolton & Fisher, 1970a' }
    end

    context 'when three authors' do
      let(:reference) do
        create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.', 'Ward, P.S.'], year: 1970, year_suffix: 'a'
      end

      specify { expect(key.key_with_suffixed_year).to eq 'Bolton <i>et al.</i>, 1970a' }
      specify { expect(key.key_with_suffixed_year.html_safe?).to eq true }
    end
  end

  describe "#key_with_year" do
    let(:reference) { create :any_reference, author_string: 'Bolton', year: 1885, year_suffix: 'g' }

    it "doesn't include the year ordinal" do
      expect(key.key_with_year).to eq 'Bolton, 1885'
    end
  end

  describe "#authors_for_key" do
    let(:reference) { create :any_reference, author_string: 'Bolton, B.', year: 1970 }

    it "escapes markup in an older author name" do
      reference.author_names.first.update_columns(name: 'O<b>x, A.')
      expect(described_class.new(reference.reload).key_with_year).to eq 'O&lt;b&gt;x, 1970'
    end
  end

  describe "HTML and plain-text forms" do
    subject(:key) { described_class.new(reference.reload) }

    let(:reference) do
      create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.', 'Ward, P.S.'], year: 1970, year_suffix: 'a'
    end

    before { reference.author_names.first.update_columns(name: "O'B<r>ien & Co, A.") }

    it "escapes the name and marks the key HTML-safe in the HTML form" do
      expect(key.key_with_suffixed_year).to eq "O'B&lt;r&gt;ien &amp; Co <i>et al.</i>, 1970a"
      expect(key.key_with_year).to eq "O'B&lt;r&gt;ien &amp; Co <i>et al.</i>, 1970"
      expect(key.key_with_suffixed_year.html_safe?).to eq true
    end

    it "keeps the name as it is, without markup, in the plain-text form" do
      expect(key.plain_text_key_with_suffixed_year).to eq "O'B<r>ien & Co et al., 1970a"
      expect(key.plain_text_key_with_year).to eq "O'B<r>ien & Co et al., 1970"
      expect(key.plain_text_authors_for_key).to eq "O'B<r>ien & Co et al."
      expect(key.plain_text_key_with_year.html_safe?).to eq false
    end

    it "is escaped once in a page" do
      template = "<p><%= key.key_with_year %></p><p><%= key.plain_text_key_with_year %></p>"
      html = ApplicationController.render(inline: template, locals: { key: key })
      expect(html).to eq "<p>O'B&lt;r&gt;ien &amp; Co <i>et al.</i>, 1970</p><p>O&#39;B&lt;r&gt;ien &amp; Co et al., 1970</p>"
    end

    context "with two authors" do
      let(:reference) { create :any_reference, author_string: ['Bolton, B.', 'Fisher, B.'], year: 1970 }

      specify do
        expect(key.plain_text_authors_for_key).to eq "O'B<r>ien & Co & Fisher"
        expect(key.authors_for_key).to eq "O'B&lt;r&gt;ien &amp; Co & Fisher"
      end
    end
  end
end
