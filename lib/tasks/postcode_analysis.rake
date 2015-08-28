

namespace :postcode_analysis do
  desc "Compare accuracy of full vs partial postcodes"
  task :partials => :environment do

    require 'artefact_retriever'
    require 'gds_api/helpers'

    transaction_slug = 'pay-council-tax'
    content_api = GdsApi::ContentApi.new(Plek.current.find("contentapi"))
    artefact_retriever = ArtefactRetriever.new(content_api, Rails.logger, nil)
    publication = PublicationPresenter.new(artefact_retriever.fetch_artefact(transaction_slug))
    controller = RootController.new()

    File.foreach('../tmp/postcode_sample.txt') do |postcode|

      postcode = UKPostcode.parse(postcode)
      location = controller.send(:fetch_location, postcode.to_s)
      full_snac = controller.send(:appropriate_snac_code_from_location, publication, location)

      next unless full_snac

      location = Frontend.mapit_api.location_for_partial_postcode(postcode.outcode)
      partial_snac = controller.send(:appropriate_snac_code_from_location, publication, location)

      puts [postcode, full_snac, partial_snac].join("\t")

      # MapIt API restrictions are 1req/sec (in a rolling 3 minute window)
      # We make 3 mapit calls, 1 for regular postcode, 2 in the partial lookup
      # so sleep for 3 seconds between iterations to stay within the limit
      sleep(3)
    end
  end
end
