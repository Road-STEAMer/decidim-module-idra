class IdraController < Decidim::ApplicationController
  def index
    # Solo per mostrare il form, i risultati vengono dalla action search
  end

  def search
    api_url = "https://idra-dev.urbreath.tech/Idra/api/v1/client/search"
    catalogues_info_url = "https://idra-dev.urbreath.tech/Idra/api/v1/client/cataloguesInfo"

    search_value = params[:search].presence || ""
    rows = (params[:rows].presence || 5).to_i
    start = (params[:start].presence || 0).to_i
    nodes = fetch_catalogue_ids(catalogues_info_url)
    filters = Idra::BuildFilters.call(params, search_value)

    payload = {
      filters: filters,
      live: false,
      sort: {
        field: params[:field].presence || "title",
        mode: "asc"
      },
      rows: rows,
      start: start,
      nodes: nodes,
      euroVocFilter: {
        euroVoc: false,
        sourceLanguage: "",
        targetLanguages: []
      }
    }

    response = Idra::Search.call(api_url, payload)
    @api_results = JSON.parse(response.body)

    respond_to do |format|
      format.html { render :index } # normale render HTML
      format.json { render json: @api_results } # solo se richiesto da JS
    end
  end

  private

  def fetch_catalogue_ids(url)
    response = Net::HTTP.get(URI(url))
    JSON.parse(response).map { |item| item["id"].to_i }
  end
end
