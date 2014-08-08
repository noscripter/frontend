require_relative '../../test_helper'

class SearchResponseTest < ActiveSupport::TestCase

  def api_response(atts={})
    {
      'results' => [],
      'total' => 1234,
      'start' => 0,
      'facets' => {},
      'suggested_queries' => [
        'something else',
      ]
    }.merge(atts)
  end

  def mock_search_query
    stub("SearchQuery")
  end

  should 'return attributes from a response hash' do
    response = SearchResponse.new(api_response, mock_search_query)

    assert_equal 1234, response.total
    assert_equal 0, response.start
    assert_equal 'something else', response.suggested_queries.first
  end

  should 'return results as result objects' do
    results = [
      {
        '_id' => '/a-slug',
        'link' => '/a-slug',
        'index' => 'mainstream',
        'es_score' => 0.1,
      },
      {
        '_id' => '/a-government-slug',
        'link' => '/a-government-slug',
        'index' => 'government',
        'es_score' => 0.1,
      },
    ]

    response = SearchResponse.new(api_response('results' => results),
                                  mock_search_query)

    mainstream_result, government_result = response.results

    assert mainstream_result.is_a?(SearchResult)
    assert_equal results[0], mainstream_result.to_hash

    assert government_result.is_a?(SearchResult)
    assert_equal results[1], government_result.to_hash
  end

end
