# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ParseAllTags do
  include TestLinksHelpers

  describe "#call" do
    context 'when sanitation is used' do
      it "sanitizes tags except <i> tags" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content]).to eq "<i>italics<i><i>xss</i></i></i>"
      end
    end

    context 'when sanitation is not used' do
      it "does not sanitize any tags" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content.dup, sanitize_content: false]).to eq content
      end
    end
  end
end
