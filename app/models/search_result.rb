class SearchResult
  def initialize(result)
    @result = result
  end

  def ==(other)
    other.respond_to?(:link) && (link == other.link)
  end

  def to_hash
    result
  end

private
  attr_reader :result

  def self.result_accessor(*keys)
    keys.each do |key|
      define_method key do
        result[key.to_s]
      end
    end
  end
  result_accessor :link, :title, :description, :format, :es_score,
                  :section, :subsection, :subsubsection, :index, :display_type,
                  :public_timestamp, :organisations, :organisation_state,
                  :world_locations

end
