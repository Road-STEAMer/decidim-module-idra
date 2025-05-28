module Decidim
    module Idra
      class ApiService
        class << self
          def fetch_catalogues_info
            get_json(ENV.fetch("IDRA_CATALOGUES_INFO_URL"))
          end
  
          def post_search(url, body)
            uri = URI(url)
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = (uri.scheme == "https")
            request = Net::HTTP::Post.new(uri)
            request["Content-Type"] = "application/json"
            request.body = JSON.dump(body)
            https.request(request)
          end
  
          private
  
          def get_json(url)
            uri = URI(url)
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = (uri.scheme == "https")
            request = Net::HTTP::Get.new(uri)
            response = https.request(request)
            JSON.parse(response.body)
          end
        end
      end
    end
  end
  