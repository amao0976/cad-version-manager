Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }

  root 'home#index'
  get 'dashboard', to: 'home#dashboard'

  get "up" => "rails/health#show", as: :rails_health_check

  get 'boms/new', to: 'boms#new', as: :new_bom
  get 'boms/:id/edit', to: 'boms#edit', as: :edit_bom
  resources :boms, except: [:new, :edit] do
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
  end
  get 'design_drawings/new', to: 'design_drawings#new', as: :new_design_drawing
  get 'design_drawings/:id/edit', to: 'design_drawings#edit', as: :edit_design_drawing

  # ===== 手表/首饰产品管理模块 =====
  get 'categories/new', to: 'categories#new', as: :new_category
  get 'categories/:id/edit', to: 'categories#edit', as: :edit_category
  resources :categories, except: [:new, :edit]

  get 'suppliers/new', to: 'suppliers#new', as: :new_supplier
  get 'suppliers/:id/edit', to: 'suppliers#edit', as: :edit_supplier
  resources :suppliers, except: [:new, :edit]

  get 'materials/new', to: 'materials#new', as: :new_material
  get 'materials/:id/edit', to: 'materials#edit', as: :edit_material
  resources :materials, except: [:new, :edit] do
    resources :material_prices, except: [:new, :edit], shallow: true
  end
  get 'materials/:material_id/material_prices/new', to: 'material_prices#new', as: :new_material_price
  get 'material_prices/:id/edit', to: 'material_prices#edit', as: :edit_material_price

  get 'products/new', to: 'products#new', as: :new_product
  get 'products/:id/edit', to: 'products#edit', as: :edit_product
  resources :products, except: [:new, :edit] do
    member do
      get 'publish', to: 'products#publish'
      get 'offline', to: 'products#offline'
      get 'calculate_price', to: 'products#calculate_price'
    end
    resources :variants, except: [:new, :edit]
  end
  get 'products/:product_id/variants/new', to: 'variants#new', as: :new_product_variant
  get 'products/:product_id/variants/:id/edit', to: 'variants#edit', as: :edit_product_variant

  resources :variants, only: [] do
    resources :batches, except: [:new, :edit] do
      member do
        post 'receive_stock', to: 'batches#receive_stock'
      end
    end
  end
  get 'variants/:variant_id/batches/new', to: 'batches#new', as: :new_variant_batch
  get 'variants/:variant_id/batches/:id/edit', to: 'batches#edit', as: :edit_variant_batch

  get 'serial_numbers/new', to: 'serial_numbers#new', as: :new_serial_number
  get 'serial_numbers/:id/edit', to: 'serial_numbers#edit', as: :edit_serial_number
  resources :serial_numbers, except: [:new, :edit] do
    member do
      get 'sell', to: 'serial_numbers#sell'
      get 'return', to: 'serial_numbers#return_item'
      get 'scrap', to: 'serial_numbers#scrap'
    end
  end

  get 'price_rules/new', to: 'price_rules#new', as: :new_price_rule
  get 'price_rules/:id/edit', to: 'price_rules#edit', as: :edit_price_rule
  resources :price_rules, except: [:new, :edit]

  namespace :api do
    namespace :v1 do
      resources :design_projects, except: [:new, :edit] do
        resources :design_drawings, except: [:new, :edit]
      end

      resources :design_drawings, except: [:new, :edit] do
        resources :drawing_versions, except: [:new, :edit]
        get 'versions', to: 'design_drawings#versions'
      end

      resources :drawing_versions, except: [:new, :edit] do
        get 'download', to: 'drawing_versions#download'
        resources :drawing_approvals, except: [:new, :edit]
      end

      get 'drawing_versions/latest/:design_drawing_id', to: 'drawing_versions#latest'

      resources :drawing_approvals, except: [:new, :edit, :destroy] do
        post 'approve', to: 'drawing_approvals#approve'
        post 'reject', to: 'drawing_approvals#reject'
      end

      get 'drawing_approvals/pending', to: 'drawing_approvals#pending'

      resources :product_boms, except: [:new, :edit] do
        post 'approve', to: 'product_boms#approve'
        post 'release', to: 'product_boms#release'
        post 'archive', to: 'product_boms#archive'
        resources :bom_items, except: [:new, :edit]
      end

      resources :bom_items, except: [:new, :edit]

      resources :categories, except: [:new, :edit]
      resources :materials, except: [:new, :edit] do
        resources :material_prices, except: [:new, :edit]
      end
      resources :products, except: [:new, :edit] do
        post 'publish', to: 'products#publish'
        post 'offline', to: 'products#offline'
        get 'calculate_price', to: 'products#calculate_price'
        resources :variants, except: [:new, :edit]
        resources :batches, except: [:new, :edit] do
          post 'receive_stock', to: 'batches#receive_stock'
        end
      end
      resources :serial_numbers, except: [:new, :edit] do
        post 'sell', to: 'serial_numbers#sell'
        post 'return', to: 'serial_numbers#return'
        post 'scrap', to: 'serial_numbers#scrap'
      end
      resources :price_rules, except: [:new, :edit]
    end
  end
end