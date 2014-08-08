class SearchResponsePresenter < SimpleDelegator
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  def initialize(response, params)
    @response = response
    @params = params

    super(response)
  end

  def to_hash
    {
      query: query,
      result_count: result_count,
      result_count_string: pluralize(number_with_delimiter(result_count), "result"),
      results_any?: results.any?,
      results: results.map { |result| result.to_hash },
      filter_fields: filter_fields,
      debug: debug?,
    }
  end

  def filter_fields
    filters = response.facets.map do |key, value|
      facet_params = params["filter_#{key.pluralize}"] || []
      facet = SearchFacetPresenter.new(value, facet_params)
      [key, facet.to_hash]
    end
    Hash[filters]
  end

  def spelling_suggestion
    response.suggested_queries.first
  end

  def result_count
    response.total
  end

  def results
    response.results.map {|result|
      presenter_class = case result.index
                        when 'government'
                          GovernmentResultPresenter
                        else
                          SearchResultPresenter
                        end
      presenter_class.new(result, debug?)
    }
  end

  def debug?
    params[:debug_score]
  end

  def query
    response.query_string
  end

private

  attr_reader :response, :params

end
