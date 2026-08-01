Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  
  namespace :api do
    namespace :v1 do
      # API Authentication
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'
      
      # Inspection API
      namespace :inspection do
        resources :requests, controller: 'requests' do
          collection do
            get :new_options
          end
          member do
            patch :schedule
            patch :cancel
          end
        end

        resources :records, controller: 'records' do
          member do
            get :report
            post :create_report
          end
          collection do
            get :pending
            get :new_options
          end
        end

        resources :reports, controller: 'reports' do
          member do
            patch :complete
            patch :reopen
            post :upload_image
            delete :remove_image
          end
        end
      end

      # Suppliers for inspection
      resources :suppliers, only: [:index, :show]
    end
  end

  root 'home#index'
  get 'dashboard', to: 'home#dashboard'

  namespace :admin do
    resources :users
  end

  get "up" => "rails/health#show", as: :rails_health_check

  resources :boms do
    get 'approve', to: 'boms#approve'
    get 'release', to: 'boms#release'
    get 'add_item', to: 'boms#add_item'
    post 'create_item', to: 'boms#create_item'
    delete 'delete_item/:item_id', to: 'boms#delete_item', as: :delete_item
  end

  resources :design_drawings do
    get 'upload_version', to: 'design_drawings#upload_version'
    post 'create_version', to: 'design_drawings#create_version'
    get 'download_version', to: 'design_drawings#download_version'
    post 'promote_version/:version_id', to: 'design_drawings#promote_version', as: :promote_version
  end

  get 'categories/import', to: 'categories#import'
  post 'categories/do_import', to: 'categories#do_import'
  get 'categories/export', to: 'categories#export'
  resources :categories

  resources :design_projects, only: [:index, :show]

  # PLM 产品生命周期管理
  get 'plm/dashboard', to: 'plm#dashboard', as: :plm_dashboard
  resources :documents do
    member do
      post 'upload_version'
      post 'submit_version'
      post 'approve_version'
      post 'release_version'
      get 'download'
    end
  end

  # Inspection 验货管理
  namespace :inspection do
    resources :requests, controller: 'requests' do
      collection do
        get :export
        post :import
      end
      member do
        patch :schedule
        patch :complete
        patch :cancel
        patch :review
        delete :remove_screenshot
        get :new_inspection
      end
    end

    resources :records, controller: 'records' do
      collection do
        get :export
        post :import
      end
      member do
        get :new_report
      end
      resource :report, controller: 'reports', only: [:new, :create, :show, :edit, :update, :destroy] do
        member do
          patch :complete
          patch :reopen
          get :export_excel
          get :export_pdf
          delete :remove_image
          post :import_size_template
          get :download_size_template_sample
        end
      end
    end

    # 验货报告独立列表
    get 'reports', to: 'reports#index'
  end

  # 供应商下属工厂管理
  scope '/suppliers' do
    resources :factories, controller: 'inspection/factories'
  end

  # 供应商管理
  resources :suppliers

  resources :materials do
    resources :material_prices, shallow: true
  end

  resources :products do
    member do
      get 'publish', to: 'products#publish'
      get 'offline', to: 'products#offline'
      get 'calculate_price', to: 'products#calculate_price'
      post 'transition', to: 'products#transition'
    end
    resources :variants
  end

  resources :variants, only: [] do
    resources :batches do
      member do
        post 'receive_stock', to: 'batches#receive_stock'
      end
    end
  end

  resources :serial_numbers do
    member do
      get 'sell', to: 'serial_numbers#sell'
      get 'return', to: 'serial_numbers#return_item'
      get 'scrap', to: 'serial_numbers#scrap'
    end
  end

  get 'colors/import', to: 'colors#import'
  post 'colors/do_import', to: 'colors#do_import'
  resources :colors

  resources :price_rules

  # 帮助中心 - 文档管理
  resources :guides, param: :slug do
    collection do
      get :admin
    end
    member do
      patch :publish
      patch :archive
    end
  end
  resources :guide_categories, param: :slug

  namespace :api do
    namespace :v1 do
      resources :design_projects do
        resources :design_drawings
      end

      resources :design_drawings do
        resources :drawing_versions
        get 'versions', to: 'design_drawings#versions'
      end

      resources :drawing_versions do
        get 'download', to: 'drawing_versions#download'
        resources :drawing_approvals
      end

      get 'drawing_versions/latest/:design_drawing_id', to: 'drawing_versions#latest'

      resources :drawing_approvals do
        post 'approve', to: 'drawing_approvals#approve'
        post 'reject', to: 'drawing_approvals#reject'
      end

      get 'drawing_approvals/pending', to: 'drawing_approvals#pending'

      resources :product_boms do
        post 'approve', to: 'product_boms#approve'
        post 'release', to: 'product_boms#release'
        post 'archive', to: 'product_boms#archive'
        resources :bom_items
      end

      resources :bom_items

      resources :categories
      resources :materials do
        resources :material_prices
      end
      resources :products do
        post 'publish', to: 'products#publish'
        post 'offline', to: 'products#offline'
        get 'calculate_price', to: 'products#calculate_price'
        resources :variants
        resources :batches do
          post 'receive_stock', to: 'batches#receive_stock'
        end
      end
      resources :serial_numbers do
        post 'sell', to: 'serial_numbers#sell'
        post 'return', to: 'serial_numbers#return'
        post 'scrap', to: 'serial_numbers#scrap'
      end
      resources :price_rules
    end
  end
end
