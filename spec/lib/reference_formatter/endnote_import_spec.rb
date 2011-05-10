require 'spec_helper'

describe ReferenceFormatter::EndnoteImport do

  it "should work" do
    reference = Factory :book_reference,
      :author_names => [Factory :author_name, :name => 'Bolton, B.'],
      :title => 'Ants Are My Life'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%A Bolton, B.
%T Ants Are My Life

}
  end

  it "should not emit %A if there is no author" do
    reference = Factory :book_reference, :title => "Ants Are My Life", :author_names => []
    ReferenceFormatter::EndnoteImport.format([reference]).should == "%T Ants Are My Life\n\n"
  end

end
