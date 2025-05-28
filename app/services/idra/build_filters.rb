module Idra
    class BuildFilters
      FILTER_FIELDS = {
        tags: "tags",
        formats: "distributionFormats",
        licenses: "distributionLicenses",
        catalogues: "catalogues",
        categories: "categories"
      }.freeze
  
      def self.call(params, search_value)
        filters = [{ "field" => "ALL", "value" => search_value }]
  
        FILTER_FIELDS.each do |param_key, field_name|
          value = params["#{param_key}_value"]
          next unless value.present?
  
          filters << {
            "field" => field_name,
            "value" => value.sub(/\A,/, "")
          }
        end
  
        filters
      end
    end
  end
  