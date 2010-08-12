class Views::References::Reference < Erector::Widget
  needs :reference

  def content
    div :id => "reference_#{@reference.id}", :class => 'reference' do
      widget Views::References::ReferenceDisplay.new :reference => @reference
      widget Views::References::ReferenceForm.new :reference => @reference
      widget Views::Coins.new :reference => @reference
    end
  end
end
