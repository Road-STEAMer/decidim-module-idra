# frozen_string_literal: true

      class ApiClient
        def initialize(api_url:, catalogues_info_url:)
          @api_url = URI(api_url)
          @catalogues_info_url = URI(catalogues_info_url)
        end
  
        def fetch_catalogues_info
          response = Net::HTTP.start(@catalogues_info_url.host, @catalogues_info_url.port, use_ssl: true) do |http|
            http.get(@catalogues_info_url)
          end
          JSON.parse(response.body)
        end
  
        def search_datasets(payload)
          request = Net::HTTP::Post.new(@api_url)
          request["Content-Type"] = "application/json"
          request.body = payload.to_json
  
          response = Net::HTTP.start(@api_url.host, @api_url.port, use_ssl: true) do |http|
            http.request(request)
          end
          JSON.parse(response.body)
        end
      end
  