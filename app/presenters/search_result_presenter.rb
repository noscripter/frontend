class SearchResultPresenter < SimpleDelegator
  include ActionView::Helpers::NumberHelper
  include ERB::Util

  SCHEME_PATTERN = %r{^https?://}
  SECTION_NAME_TRANSLATION = {
    "life-in-the-uk" => "Life in the UK",
    "council-tax" => "Council Tax",
    "housing-benefits-grants-and-schemes" => "Housing benefits, grants and schemes",
    "work-related-benefits-and-schemes" => "Work-related benefits and schemes",
    "buying-selling-a-vehicle" => "Buying/selling a vehicle",
    "owning-a-car-motorbike" => "Owning a car/motorbike",
    "council-and-housing-association-homes" => "Council and housing association homes",
    "animals-food-and-plants" => "Animals, food and plants",
    "mot" => "MOT",
    "mot-insurance" => "MOT insurance",
    "Inside Government" => "Inside Government"
  }

  def initialize(result, debug=false)
    @result = result
    @debug = debug

    super(result)
  end

  %w(section subsection subsubsection).each do |key|
    define_method "formatted_#{key}_name" do
      mapped_name(send(key)) || humanized_name(send(key))
    end
  end

  # External links have a truncated version of their URLs displayed on the
  # results page, but there's little benefit to displaying the URL scheme
  def display_link
    link.sub(SCHEME_PATTERN, '').truncate(48) if link
  end

  # override the `format` method included in the ActionView module to explicitly
  # delegate this to the result object
  def format
    result.format
  end

  def to_hash
    {
      debug: debug,
      title: title,
      link: link,
      description: description,
      external: result.format == "recommended-link",
      display_link: display_link,
      section: section,
      formatted_section_name: (formatted_section_name if section),
      formatted_subsection_name: (formatted_subsection_name if subsection),
      formatted_subsubsection_name: (formatted_subsubsection_name if subsubsection),
      attributes: [],
      es_score: formatted_es_score,
      format: result.format
    }
  end

protected

  attr_reader :debug, :result

  def formatted_es_score
    number_with_precision(es_score * 1000, significant: true, precision: 4) if es_score
  end

  def mapped_name(var)
    return SECTION_NAME_TRANSLATION[var] ? SECTION_NAME_TRANSLATION[var] : false
  end

  def humanized_name(name)
    name.gsub('-', ' ').capitalize
  end

end
