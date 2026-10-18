# frozen_string_literal: true

require 'rails_helper'

describe AntCatVersionLink do
  describe "#call" do
    context "when the commit is known" do
      let(:sha) { "5166c5a2#{'0' * 32}" }

      before { stub_const("AntCat::COMMIT", sha) }

      it "links the version and short hash to the commit" do
        html = described_class.new.call
        expect(html).to include %(href="https://github.com/calacademy-research/antcat/commit/#{sha}")
        expect(html).to include "Version #{AntCat::VERSION} (5166c5a)"
      end
    end

    context "when the commit is not known" do
      before { stub_const("AntCat::COMMIT", nil) }

      it "links the version to the release notes" do
        html = described_class.new.call
        expect(html).to include %(href="https://github.com/calacademy-research/antcat/releases")
        expect(html).not_to include "/commit/"
      end
    end
  end
end
