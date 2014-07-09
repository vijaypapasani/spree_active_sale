Spree::Core::Engine.routes.draw do
  # Add this extension's routes here
  get 'admin/active_sales/:active_sale_id/active_sale_events/:id/sort' => 'admin/active_sale_events#sort_sales', :as => :sort_sales
  post '/admin/active_sales/:active_sale_id/active_sale_events/:id/update_sales' => 'admin/active_sale_events#sort_update_sales', :as => :update_sales
  post '/update_designer_sales' => 'admin/active_sale_events#designer_sort_update_sales', :as => :update_designer_sales
  namespace :admin do
    resources :active_sales do
      collection do
        get  :eventables
        post :update_positions
      end
      member do
        get :get_children
      end
      resources :active_sale_events do
        member do
          put :update_events
        end
        resources :sale_images do
          collection do
            post :update_positions
          end
        end
      end
    end
  end
end
