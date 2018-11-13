require 'spec_helper'

describe ApplicationMailer do
  specify { expect(described_class.new).to be_a ActionMailer::Base }
end
