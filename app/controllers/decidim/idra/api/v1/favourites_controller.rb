module Decidim
  module Idra
    module Api
      module V1
        class FavouritesController < Decidim::ApplicationController
          before_action :authenticate_user!
          before_action :set_favorite, only: [:show, :destroy]

          def index
            favourites = current_user.saved_datasets
            render json: favourites
          end

          def create
            favourite = SavedDatasets.new(
              dataset_id: params[:dataset_id],
              title: params[:title],
              url: params[:url],
              decidim_user: current_user
            )
            
            if favourite.save
              render json: favourite, status: :created
            else
              render json: { errors: favourite.errors.full_messages }, status: :unprocessable_entity
            end
          end

          def show
            render json: @favorite
          end

          def list
            @datasets = current_user.saved_datasets
            render partial: "idra/datasets_list", layout: false
          end
          

          def destroy
            if @favorite.destroy
              head :no_content
            else
              render json: { error: "Impossibile eliminare il preferito" }, status: :unprocessable_entity
            end
          end

          private

          def favorite_params
            params.permit(:title, :dataset_id, :url)
          end
          

          def set_favorite
            @favorite = current_user.saved_datasets.find_by(dataset_id: params[:id])
            render json: { error: "Non trovato" }, status: :not_found unless @favorite
          end
        end
      end
    end
  end
end
