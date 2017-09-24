require 'spec_helper'

describe Reference do
  let(:reference) { create :article_reference }

  it "starts as 'none'" do
    expect(reference).to be_none
    expect(reference.can_start_reviewing?).to be true
    expect(reference.can_finish_reviewing?).to be false
    expect(reference.can_restart_reviewing?).to be false
  end

  it "none transitions to start" do
    reference.start_reviewing!
    expect(reference).to be_reviewing
    expect(reference.can_start_reviewing?).to be false
    expect(reference.can_finish_reviewing?).to be true
    expect(reference.can_restart_reviewing?).to be false
  end

  it "start transitions to finish" do
    reference.start_reviewing!
    reference.finish_reviewing!
    expect(reference).not_to be_reviewing
    expect(reference).to be_reviewed
    expect(reference.can_start_reviewing?).to be false
    expect(reference.can_finish_reviewing?).to be false
    expect(reference.can_restart_reviewing?).to be true
  end

  it "reviewed can transition back to reviewing" do
    reference.start_reviewing!
    reference.finish_reviewing!
    reference.restart_reviewing!
    expect(reference).to be_reviewing
    expect(reference.can_start_reviewing?).to be false
    expect(reference.can_finish_reviewing?).to be true
    expect(reference.can_restart_reviewing?).to be false
  end
end
