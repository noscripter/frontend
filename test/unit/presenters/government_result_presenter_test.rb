require_relative "../../test_helper"

class GovernmentResultPresenterTest < ActiveSupport::TestCase
  def build_search_result(attributes = {})
    SearchResult.new(attributes)
  end

  should "display a description" do
    result = GovernmentResultPresenter.new(build_search_result("description" => "I like pie."))
    assert_equal "I like pie.", result.description
  end

  should "truncate descriptions at word boundaries" do
    long_description = %Q{You asked me to oversee a strategic review of
Directgov and to report to you by the end of September. I have undertaken this
review in the context of my wider remit as UK Digital Champion which includes
offering advice on "how efficiencies can best be realised through the online
delivery of public services."}
    truncated_description = %Q{You asked me to oversee a strategic review of
Directgov and to report to you by the end of September. I have undertaken this
review in the context of my wider remit as UK Digital Champion which includes
offering...}
    result = GovernmentResultPresenter.new(build_search_result("description" => long_description))
    assert_equal truncated_description, result.description
  end

  should "report a lack of location field as no locations" do
    result = GovernmentResultPresenter.new(build_search_result)
    assert result.metadata.empty?
  end

  should "report an empty list of locations as no locations" do
    result = GovernmentResultPresenter.new(build_search_result("world_locations" => []))
    assert result.metadata.empty?
  end

  should "display a single world location" do
    france = {"title" => "France", "slug" => "france"}
    result = GovernmentResultPresenter.new(build_search_result("world_locations" => [france]))
    assert_equal "France", result.metadata[0]
  end

  should "not display individual locations when there are several" do
    france = {"title" => "France", "slug" => "france"}
    spain = {"title" => "Spain", "slug" => "spain"}
    result = GovernmentResultPresenter.new(build_search_result("world_locations" => [france, spain]))
    assert_equal "multiple locations", result.metadata[0]
  end

  should "return valid metadata" do
    result = GovernmentResultPresenter.new(build_search_result({
      "public_timestamp" => "2014-10-14",
      "display_type" => "my-display-type",
      "organisations" => [ { "slug" => "org-1" } ],
      "world_locations" => [ {"title" => "France", "slug" => "france"} ]
    }))
    assert_equal [ '14 October 2014', 'my-display-type', 'org-1', 'France' ], result.metadata
  end

  should "return format for corporate information pages in metadata" do
    result = GovernmentResultPresenter.new(build_search_result({
      "format" => "corporate_information"
    }))
    assert_equal [ 'Corporate information' ], result.metadata
  end

  should "return only display type for corporate information pages if it is present in metadata" do
    result = GovernmentResultPresenter.new(build_search_result({
      "display_type" => "my-display-type",
      "format" => "corporate_information"
    }))
    assert_equal [ "my-display-type" ], result.metadata
  end

  should "not return sections for deputy prime ministers office" do
    result = GovernmentResultPresenter.new(build_search_result({
      "format" => "organisation",
      "link" => "/government/organisations/deputy-prime-ministers-office",
    }))
    assert_nil result.sections
  end

  should "return sections for some format types" do
    minister_results               = GovernmentResultPresenter.new(build_search_result({ "format" => "minister" }))
    organisation_results           = GovernmentResultPresenter.new(build_search_result({ "format" => "organisation" }))
    person_results                 = GovernmentResultPresenter.new(build_search_result({ "format" => "person" }))
    world_location_results         = GovernmentResultPresenter.new(build_search_result({ "format" => "world_location" }))
    worldwide_organisation_results = GovernmentResultPresenter.new(build_search_result({ "format" => "worldwide_organisation" }))
    mainstream_results             = GovernmentResultPresenter.new(build_search_result({ "format" => "mainstream" }))

    assert_equal 2, minister_results.sections.length
    assert_equal nil, organisation_results.sections
    assert_equal 2, person_results.sections.length
    assert_equal 2, world_location_results.sections.length
    assert_equal 2, worldwide_organisation_results.sections.length

    assert_equal nil, mainstream_results.sections
  end

  should "return sections in correct format" do
    minister_results = GovernmentResultPresenter.new(build_search_result({ "format" => "minister" }))

    assert_equal [:hash, :title], minister_results.sections.first.keys
  end

  should "return description for detailed guides" do
    result = GovernmentResultPresenter.new(build_search_result({
      "format" => "detailed_guidance",
      "description" => "my-description"
    }))
    assert_equal 'my-description', result.description
  end

  should "return description for organisation" do
    result = GovernmentResultPresenter.new(build_search_result({
      "format" => "organisation",
      "title" => "my-title",
      "description" => "my-description"
    }))
    assert_equal 'The home of my-title on GOV.UK. my-description', result.description
  end

  should "return description for other formats" do
    result = GovernmentResultPresenter.new(build_search_result({
      "format" => "my-new-format",
      "description" => "my-description"
    }))
    assert_equal 'my-description', result.description
  end

  should "mark titles of closed organisations as being closed" do
    result = GovernmentResultPresenter.new(build_search_result({
      "format" => "organisation",
      "organisation_state" => "closed",
      "title" => "my-title",
      "description" => "my-description",
    }))
    assert_equal 'Closed organisation: my-title', result.title
    assert_equal 'my-description', result.description
  end
end
