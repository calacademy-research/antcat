class AutofillDemosController < ApplicationController
  def index
  end

  def show
    search_expression = '%' + params[:term].split('').join('%') + '%'
    journal_titles = Reference.find_by_sql("select distinct short_journal_title from refs where short_journal_title like '#{search_expression}' order by short_journal_title")
    journal_titles = journal_titles.map {|e| e['short_journal_title']}
    lll { 'journal_titles' }
    render :json => journal_titles.to_json
  end
end
