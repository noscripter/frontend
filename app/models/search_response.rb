class SearchResponse

  attr_reader :query

  def initialize(response, query)
    @response = response
    @query = query
  end

  def results
    response['results'].map do |result|
      SearchResult.new(result)
    end
  end

private
  attr_reader :response

  def self.response_accessor(*keys)
    keys.each do |key|
      define_method key do
        response[key.to_s]
      end
    end
  end
  response_accessor :facets, :suggested_queries, :start, :total

end
