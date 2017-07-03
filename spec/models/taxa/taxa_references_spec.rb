require 'spec_helper'

describe Taxon do
  subject { create_genus 'Atta' }

  describe "#references" do
    it "calls `Taxa::WhatLinksHere`" do
      expect(Taxa::WhatLinksHere).to receive(:new).with(subject).and_call_original
      subject.references
    end
  end

  describe "#nontaxt_references" do
    it "calls `Taxa::WhatLinksHere`" do
      expect(Taxa::WhatLinksHere).to receive(:new).with(subject).and_call_original
      subject.nontaxt_references
    end
  end

  describe "#any_nontaxt_references?" do
    it "calls `Taxa::WhatLinksHere`" do
      expect(Taxa::WhatLinksHere).to receive(:new).with(subject).and_call_original
      subject.any_nontaxt_references?
    end
  end
end
