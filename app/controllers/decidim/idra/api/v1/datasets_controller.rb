# app/controllers/decidim/idra/api/v1/datasets_controller.rb
module Decidim
    module Idra
      module Api
        module V1
          class DatasetsController < ApplicationController
            def index
              datasets = Decidim::Idra::Dataset.all
  
              datasets = apply_filters(datasets)
              datasets = apply_search(datasets)
              datasets = datasets.page(params[:page]).per(10)
  
              render json: {
                datasets: datasets.as_json(only: [:id, :title, :description, :url]),
                pagination: {
                  current_page: datasets.current_page,
                  total_pages: datasets.total_pages,
                  total_count: datasets.total_count
                }
              }
            end
  
            private
  
            def apply_filters(scope)
              scope = scope.where(category: params[:category]) if params[:category].present?
              scope
            end
  
            def apply_search(scope)
              return scope unless params[:q].present?
  
              q = params[:q].strip
              scope.where("title ILIKE :q OR description ILIKE :q", q: "%#{q}%")
            end
          end
        end
      end
    end
  end
  