class IdraController < Decidim::ApplicationController
  def index
    @api_url = params[:api_url].presence || default_api_url
    @catalogues_info_url = params[:api_catalogues_info_url].presence || default_catalogues_info_url

    client = ApiClient.new(api_url: @api_url, catalogues_info_url: @catalogues_info_url)
    catalogues_info = client.fetch_catalogues_info
    nodes = catalogues_info.map { |cat| cat["id"].to_i }

    filters = build_filters(params)

    @page = params[:page].to_i
    @page = 1 if @page < 1
    @per_page = (params[:rows] || 5).to_i
    start = (@page - 1) * @per_page

    payload = build_payload(filters, nodes, start, @per_page)

    @api_results = client.search_datasets(payload)
    @total_results = @api_results["count"]

    extract_facets(@api_results)
    load_user_datasets

    render "decidim/idra/index"
  end

  private

  def default_api_url
    "https://idra-dev.urbreath.tech/Idra/api/v1/client/search"
  end

  def default_catalogues_info_url
    "https://idra-dev.urbreath.tech/Idra/api/v1/client/cataloguesInfo"
  end

  def build_filters(params)
    filters = [{ field: "ALL", value: params[:search].presence || "" }]

    %i[tags_value formats_value licenses_value catalogues_value categories_value].each do |key|
      if params[key].present?
        filters << {
          field: key.to_s.gsub("_value", ""),
          value: params[key].delete_prefix(",")
        }
      end
    end
    filters
  end

  def build_payload(filters, nodes, start, rows)
    {
      filters: filters,
      live: false,
      sort: { field: params[:field].presence || "title", mode: "asc" },
      rows: rows,
      start: start,
      nodes: nodes,
      euroVocFilter: { euroVoc: false, sourceLanguage: "", targetLanguages: [] }
    }
  end

  def extract_facets(api_results)
    facets = api_results["facets"] || []
    @tags, @formats, @licenses, @catalogues, @categories = facets[0..4]
  end

  def load_user_datasets
    @datasets = SavedDatasets.where(decidim_user: current_user)
    @element_count = @datasets.count
    @list = @datasets.pluck(:dataset_id)
  end
end
