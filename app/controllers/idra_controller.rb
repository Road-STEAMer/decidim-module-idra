class IdraController < Decidim::ApplicationController
  def index
    @api_url = params[:api_url].presence || "https://idra-ext.urbreath.tech/Idra/api/v1/client/search"
    @api_catalogues_info_url = params[:api_catalogues_info_url] || "https://idra-ext.urbreath.tech/Idra/api/v1/client/cataloguesInfo"

    https = Net::HTTP.new(URI(@api_url).host, URI(@api_url).port).tap { |http| http.use_ssl = true }
    catalogue_https = Net::HTTP.new(URI(@api_catalogues_info_url).host, URI(@api_catalogues_info_url).port).tap { |http| http.use_ssl = true }

    catalogue_info_data = JSON.parse(catalogue_https.request(Net::HTTP::Get.new(URI(@api_catalogues_info_url))).body)
    @nodes = catalogue_info_data.map { |c| c["id"].to_i }

    @search_value = params[:search].to_s.strip.split(/\s+/).reject(&:blank?).join(",")
    @rows = (params[:rows] || 5).to_i
    @start = (params[:start] || 0).to_i
    field = params[:field].presence || "title"

    filters = [{ field: "ALL", value: @search_value }]
    {
      tags: "tags_value",
      distributionFormats: "formats_value",
      distributionLicenses: "licenses_value",
      catalogues: "catalogues_value",
      datasetThemes: "categories_value" # ← cambia qui da "categories" a "datasetThemes"
    }.each do |filter_field, param_key|
      val = params[param_key]
      filters << { field: filter_field.to_s, value: val.sub(/^,/, "") } if val.present?
      instance_variable_set("@#{param_key}", val)
    end

    req = Net::HTTP::Post.new(URI(@api_url))
    req["Content-Type"] = "application/json"
    req.body = {
      filters: filters,
      live: false,
      sort: { field: field, mode: "asc" },
      rows: @rows,
      start: @start,
      nodes: @nodes,
      euroVocFilter: { euroVoc: false, sourceLanguage: "", targetLanguages: [] }
    }.to_json

    @api_results = JSON.parse(https.request(req).read_body)
    @total_results = @api_results["count"]

    if @api_results["facets"]
      %w[tags formats licenses catalogues datasetThemes].each_with_index do |name, i|
        var_name = name == "datasetThemes" ? "categories" : name
        instance_variable_set("@#{var_name}", @api_results["facets"][i])
        instance_variable_set("@#{var_name}_values", @api_results["facets"][i]["values"])
      end
    end

    @selected_filters = %w[tags_value formats_value licenses_value catalogues_value categories_value].map { |f| params[f]&.split(",") }.compact
    @selected_filters.delete(params[:deleted_filter]) if params[:deleted_filter].present?

    @datasets = SavedDatasets.where(decidim_user: current_user)
    @element_count = @datasets.count
    @list = @datasets.pluck(:dataset_id)

    render "idra/index"
  end



    def create
      selected_title = params[:selected_titles]
      selected_dataset_id = params[:selected_dataset_id]
      @selected_dataset_id = selected_dataset_id
      selected_url = params[:selected_url]
  
      unless SavedDatasets.exists?(dataset_id: selected_dataset_id, decidim_user: current_user)
        saved_dataset = SavedDatasets.create(title: selected_title, decidim_user: current_user, url: selected_url, dataset_id: selected_dataset_id)
        @datasets = SavedDatasets.where(decidim_user: current_user)
      end
  
      render partial: "datasets_list"
    end
    
  
def delete
  dataset_id = params[:selected_dataset_id]
  dataset = SavedDatasets.find_by(dataset_id: dataset_id, decidim_user: current_user)

  if dataset.present? && dataset.destroy
    # Dataset successfully deleted
    render partial: "datasets_list"
  else
    # Handle error if dataset not found or couldn't be deleted
    render json: { error: 'Could not delete dataset' }, status: :unprocessable_entity
  end
end

  
  def update
    @datasets = SavedDatasets.where(decidim_user: current_user)
    render partial: "datasets_list"
  end


  def modal_editor
    @datasets = SavedDatasets.where(decidim_user: current_user)
    render partial: "datasets_list"
  end

  def datasets
    @datasets = SavedDatasets.where(decidim_user: current_user)
    respond_to do |format|
      format.json { render json: @datasets }
    end
  end
end