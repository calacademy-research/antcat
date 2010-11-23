require 'spec_helper'

describe Author do
  it "has many names" do
    author = Author.create!
    author.names << Factory(:author_name)
    author.should have(1).name
  end
end
