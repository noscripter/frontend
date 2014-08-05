require_relative '../../test_helper'

class SearchQueryTest < ActiveSupport::TestCase

  def build_search_query(atts = {})
    {
      start: nil,
      count: SearchQuery::DEFAULT_RESULTS_PER_PAGE,
      q: nil,
      filter_organisations: nil,
      fields: SearchQuery::FIELDS,
      facet_organisations: '100',
      debug: nil,
    }.merge(atts)
  end

  def base_response
    {
      'results' => []
    }
  end

  # Stub out the search client on the provided search query object, and set an
  # expectation that a particular request will be made. When the request is
  # made, return the provided response.
  def expect_search_request(options={})
    mock_search_client = mock('ApiClient')

    options[:search_query].stubs(:search_client)
                          .returns(mock_search_client)

    mock_search_client.expects(:unified_search)
                      .with(options[:expected_request])
                      .returns(options[:response])
  end

  should 'perform a search given a query parameter' do
    query = SearchQuery.new(query: 'cheese')

    expect_search_request(
      search_query: query,
      expected_request: build_search_query(q: 'cheese'),
      response: base_response
    )

    assert query.perform
    assert_equal base_response, query.response
  end

  context '#count' do
    should 'use the default count value when nil' do
      query = SearchQuery.new(query: 'cheese', count: nil)

      expect_search_request(
        search_query: query,
        expected_request: build_search_query(
          q: 'cheese',
          count: SearchQuery::DEFAULT_RESULTS_PER_PAGE,
        ),
        response: base_response
      )

      assert query.perform
      assert_equal base_response, query.response
    end

    should 'allow a custom count value' do
      query = SearchQuery.new(query: 'cheese', count: 30)

      expect_search_request(
        search_query: query,
        expected_request: build_search_query(q: 'cheese', count: 30),
        response: base_response
      )

      assert query.perform
      assert_equal base_response, query.response
    end

    should 'limit the count value to the maximum allowed' do
      high_value = SearchQuery::MAX_RESULTS_PER_PAGE + 20
      query = SearchQuery.new(query: 'cheese', count: high_value)

      expect_search_request(
        search_query: query,
        expected_request: build_search_query(
          q: 'cheese',
          count: SearchQuery::MAX_RESULTS_PER_PAGE,
        ),
        response: base_response
      )

      assert query.perform
      assert_equal base_response, query.response
    end

    should 'use the default count value when < 0' do
      query = SearchQuery.new(query: 'cheese', count: -1)

      expect_search_request(
        search_query: query,
        expected_request: build_search_query(
          q: 'cheese',
          count: SearchQuery::DEFAULT_RESULTS_PER_PAGE,
        ),
        response: base_response
      )

      assert query.perform
      assert_equal base_response, query.response
    end
  end

end
