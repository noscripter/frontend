require "slimmer/headers"

class SearchController < ApplicationController

  before_filter :setup_slimmer_artefact, only: :index
  before_filter :set_expiry

  rescue_from GdsApi::BaseError, with: :error_503

  def index
    @search_term = params[:q]
    if @search_term.blank? && params[:format] != "json"
      render action: 'no_search_term' and return
    end

    @query = SearchQuery.new(
      start: params[:start],
      count: params[:count],
      query: @search_term,
      debug: params[:debug],
      filter_organisations: [*params[:filter_organisations]],
    )
    @query.perform

    @results = SearchResultsPresenter.new(@query, params)
    @facets = @query.response["facets"]
    @spelling_suggestion = @results.spelling_suggestion

    fill_in_slimmer_headers(@results.result_count)

    respond_to do |format|
      format.html
      format.json do
        render json: @results
      end
    end
  end

protected

  def fill_in_slimmer_headers(result_count)
    set_slimmer_headers(
      result_count: result_count,
      format:       "search",
      section:      "search",
      proposition:  "citizen"
    )
  end

  def setup_slimmer_artefact
    set_slimmer_dummy_artefact(:section_name => "Search", :section_link => "/search")
  end
end
