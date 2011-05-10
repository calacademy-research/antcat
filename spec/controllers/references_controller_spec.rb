require 'spec_helper'

describe ReferencesController do
  render_views

  it "should use ReferencesController" do
    fisher_reference = Factory :reference, :author_names => [Factory :author_name, :name => 'Fisher, B.L.']
    fisher_reference.should_receive(:to_bibix).and_return 'Fisher'
    bolton_reference = Factory :reference, :author_names => [Factory :author_name, :name => 'Bolton']
    bolton_reference.should_receive(:to_bibix).and_return 'Bolton'
    Reference.should_receive(:do_search).and_return [bolton_reference, fisher_reference]
    get 'index', :format => 'bibix'
    response.body.should == "Bolton\nFisher\n"
  end

end
