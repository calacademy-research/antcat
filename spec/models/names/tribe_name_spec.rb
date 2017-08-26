require 'spec_helper'

describe TribeName do
  subject { described_class.new name: 'Attini', name_html: "Attini" }

  describe "#to_s" do
    specify { expect(subject.to_s).to eq 'Attini' }
  end

  describe "#to_html" do
    specify { expect(subject.to_html).to eq 'Attini' }
  end
end
