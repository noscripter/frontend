require_relative "../../test_helper"

class SearchResponsePresenterTest < ActiveSupport::TestCase

  def mock_search_query(query, response)
    query = stub("SearchQuery", query: query)
    SearchResponse.new(response, query)
  end

  should "return an appropriate hash" do
    query = mock_search_query('my-query', {
      "total" => 1,
      "results" => [ { "index" => "mainstream" } ],
      "facets" => []
    })

    results = SearchResponsePresenter.new(query, {})
    assert_equal 'my-query', results.to_hash[:query]
    assert_equal 1, results.to_hash[:result_count]
    assert_equal '1 result', results.to_hash[:result_count_string]
    assert_equal true, results.to_hash[:results_any?]
  end

  should "return an entry for a facet" do
    query = mock_search_query('my-query', {
      "results" => [],
      "facets" => {
        "organisations" => {
          "options" => [ {
            "value" => {
              "link" => "/government/organisations/department-for-education",
              "title" => "Department for Education"
            },
            "documents" => 114
          } ]
        }
      }
    })

    results = SearchResponsePresenter.new(query, {})

    assert results.to_hash[:filter_fields]["organisations"]
    assert_equal 1, results.to_hash[:filter_fields]["organisations"][:options].length
    assert_equal "Department for Education", results.to_hash[:filter_fields]["organisations"][:options][0][:title]
  end
end
