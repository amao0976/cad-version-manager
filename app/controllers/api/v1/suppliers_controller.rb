module Api
  module V1
    class SuppliersController < BaseController
      # GET /api/v1/suppliers
      def index
        suppliers = Supplier.all.order(name: :asc)
        
        if params[:keyword].present?
          keyword = "%#{params[:keyword]}%"
          suppliers = suppliers.where(
            "name LIKE :kw OR code LIKE :kw",
            kw: keyword
          )
        end
        
        render json: {
          data: suppliers.map { |s| serialize_supplier(s) }
        }
      end
      
      # GET /api/v1/suppliers/:id
      def show
        supplier = Supplier.find(params[:id])
        render json: { data: serialize_supplier(supplier) }
      end
      
      private
      
      def serialize_supplier(supplier)
        {
          id: supplier.id,
          code: supplier.code,
          name: supplier.name,
          supplier_type: supplier.supplier_type,
          contact_name: supplier.contact_name,
          contact_phone: supplier.contact_phone,
          status: supplier.status
        }
      end
    end
  end
end
