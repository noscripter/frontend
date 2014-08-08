class SearchQuery
  attr_reader :start, :query, :debug, :filter_organisations

  FIELDS = %w{
    description
    display_type
    document_series
    format
    link
    organisations
    organisation_state
    public_timestamp
    section
    slug
    specialist_sectors
    subsection
    subsubsection
    title
    topics
    world_locations
  }

  DEFAULT_RESULTS_PER_PAGE = 50
  MAX_RESULTS_PER_PAGE = 100

  def initialize(params)
    @start = params[:start]
    @count = params[:count]
    @query = params[:query]
    @debug = params[:debug]
    @filter_organisations = params[:filter_organisations]
  end

  def perform
    @response_body = search_client.unified_search(payload)
    SearchResponse.new(@response_body, self)
  end

  def count
    count = @count.nil? ? 0 : @count.to_i
    if count <= 0
      count = DEFAULT_RESULTS_PER_PAGE
    elsif count > MAX_RESULTS_PER_PAGE
      count = MAX_RESULTS_PER_PAGE
    end
    count
  end

  def facet_organisations
    "100"
  end

private

  def payload
    {
      start: start,
      count: count,
      q: query,
      filter_organisations: filter_organisations,
      fields: FIELDS,
      facet_organisations: facet_organisations,
      debug: debug,
    }
  end

  def search_client
    Frontend.search_client
  end
end
