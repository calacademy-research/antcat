module References
  class SearchController < ApplicationController
    before_action :redirect_if_search_matches_id, only: :index
    layout "references"

    def index
      return redirect_to references_path unless user_is_searching?

      unparsable_author_names_error_message = <<-MSG
        Could not parse author names. Start by typing a name, wait for a while
        and then click on one of the suggestions. It is possible to manually
        type the query (for example "Wilson, E. O.; Billen, J.;"),
        but the names must exactly match the names in the database
        ("Wilson" or "Wilson, E." will not work), and the query has to be
        formatted like in the first example. Still not working? Email us!
      MSG

      @references = if params[:search_type] == "author"
                      begin
                        Reference.author_search params[:author_q], params[:page]
                      rescue Citrus::ParseError
                        flash.now.alert = unparsable_author_names_error_message
                        Reference.none.paginate page: 9999
                      end
                    else
                      Reference.do_search params
                    end
    end

    def help
    end

    private
      def user_is_searching?
        params[:q].present? || params[:author_q].present?
      end

      def redirect_if_search_matches_id
        params[:q] ||= ''
        params[:q].strip!

        if params[:q].match(/^\d{5,}$/)
          id = params[:q]
          return redirect_to reference_path(id) if Reference.exists? id
        end
      end
  end
end
