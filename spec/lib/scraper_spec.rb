require 'spec_helper'

require 'curl'

describe Scraper do
  it "should call Curl appropriately" do
    result = mock
    Curl::Easy.should_receive(:perform).with('foo').and_return result
    result.should_receive(:body_str).and_return 'bar'
    Nokogiri.should_receive(:HTML).with('bar').and_return 'foobar'

    result = Scraper.new.get('foo')

    result.should == 'foobar'
  end
end
