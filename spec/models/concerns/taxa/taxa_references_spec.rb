require 'spec_helper'

describe Taxon do
  subject { create_genus 'Atta' }

  describe "#what_links_here" do
    it "calls `Taxa::WhatLinksHere`" do
      expect(Taxa::WhatLinksHere).to receive(:new).with(subject).and_call_original
      subject.what_links_here
    end
  end

  describe "#any_nontaxt_references?" do
    it "calls `Taxa::AnyNonTaxtReferences`" do
      expect(Taxa::AnyNonTaxtReferences).to receive(:new).with(subject).and_call_original
      subject.any_nontaxt_references?
    end
  end
end
