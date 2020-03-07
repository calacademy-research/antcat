require 'rails_helper'
require_relative '../../script/site_notice_template'

describe SiteNoticeTemplate do
  describe '#filename', :skip_ci do
    specify do
      expect(described_class.new.filename).to match(/site_notice_v\d+.\d+.\d+/)
    end
  end
end
