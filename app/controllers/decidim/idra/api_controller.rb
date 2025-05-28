module Decidim
    module Idra
      class ApiController < Decidim::ApplicationController
        FILTER_PARAMS_MAP = {
          tags_value: "tags",
          formats_value: "distributionFormats",
          licenses_value: "distributionLicenses",
          catalogues_value: "catalogues",
          categories_value: "categories"
        }.freeze
  
        def search
          catalogues_info = ApiService.fetch_catalogues_info
  
          filters = build_filters(params)
  
          body = {
            filters: filters,
            live: false,
            sort: {
              field: params[:field].presence || "title",
              mode: "asc"
            },
            rows: (params[:rows] || 5).to_i,
            start: (params[:start] || 0).to_i,
            nodes: catalogues_info.map { |c| c["id"].to_i },
            euroVocFilter: {
              euroVoc: false,
              sourceLanguage: "",
              targetLanguages: []
            }
          }
  
          response = ApiService.post_search(api_url, body)
          api_results = JSON.parse(response.body)
  
          render json: {
            results: api_results["results"] || [],
            count: api_results["count"] || 0,
            facets: api_results["facets"] || []
          }
        rescue StandardError => e
          render json: { error: e.message }, status: :bad_gateway
        end
  
        private
  
        def api_url
          ENV.fetch("IDRA_API_URL")
        end
  
        def build_filters(params)
          filters = [{ field: "ALL", value: params[:search].presence || '""' }]
  
          FILTER_PARAMS_MAP.each do |param_key, field_name|
            val = params[param_key]
            next if val.blank?
  
            val = val.start_with?(",") ? val[1..-1] : val
            filters << { field: field_name, value: val }
          end
  
          filters
        end
      end
    end
  end
  