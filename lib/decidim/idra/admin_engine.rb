# frozen_string_literal: true

module Decidim
  module Idra
    # This is the engine that runs on the public interface of `Idra`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Idra::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :idra do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "idra#index"
      end

      def load_seed
        nil
      end
    end
  end
end
