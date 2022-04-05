# frozen_string_literal: true

Rails.application.routes.draw do
  Spree::Core::Engine.routes.draw do
    namespace :admin do
      scope '/:vendor_id/' do
        resources :commission_settings do
          collection do
            get :qualifying_values, format: :json
          end
        end
      end
    end
    namespace :api, defaults: { format: 'json' } do
      namespace :v1 do
        resources :orders_request, only: [:create]
      end
    end
    post 'approve_products' => 'products#approve_products'
  end
  mount Spree::Core::Engine, at: '/'
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  if Rails.env.production? || Rails.env.staging?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.SIDEKIQ_USERNAME)) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.SIDEKIQ_PASSWORD))
    end
  end
  mount Sidekiq::Web, at: '/sidekiq'
end
