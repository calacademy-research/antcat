class Views::Search < Erector::Widget
  def content
    div :id => 'search' do
      widget Form, :action => '/references', :method => 'get' do
        label 'Author', :for => 'author'
        input :name => 'author', :id => 'author', :type => 'text', :value => params[:author]

        label 'Year', :for => 'start_year'
        input :name => 'start_year', :id => 'start_year', :class => 'year', :type => 'text', :value => params[:start_year]

        label 'to', :for => 'end_year'
        input :name => 'end_year', :id => 'end_year', :class => 'year', :type => 'text', :value => params[:end_year]

        label 'Journal', :for => 'journal'
        input :name => 'journal', :id => 'journal', :type => 'text', :value => params[:journal]

        button 'Search', :value => 'search', :name => 'commit', :type => 'submit'
        button 'Clear', :value => 'clear', :name => 'commit', :type => 'submit'
      end
    end
  end
end
