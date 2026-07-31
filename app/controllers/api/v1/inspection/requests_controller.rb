module Api
  module V1
    module Inspection
      class RequestsController < BaseController
        before_action :set_request, only: [:show, :schedule, :complete, :cancel]
        
        # GET /api/v1/inspection/requests
        def index
          requests = ::Inspection::Request.includes(:supplier, :product, :items)
          
          if params[:status].present?
            requests = requests.where(status: params[:status])
          end
          
          if params[:keyword].present?
            keyword = "%#{params[:keyword]}%"
            requests = requests.where(
              "order_number LIKE :kw OR style_number LIKE :kw",
              kw: keyword
            )
          end
          
          requests = requests.order(created_at: :desc)
          
          paginated = paginate(requests)
          render json: {
            data: paginated[:data].map { |r| serialize_request(r) },
            meta: paginated[:meta]
          }
        end
        
        # GET /api/v1/inspection/requests/:id
        def show
          render json: { data: serialize_request(@request) }
        end
        
        # PATCH /api/v1/inspection/requests/:id/schedule
        def schedule
          if @request.may_schedule?
            @request.schedule!
            render json: { data: serialize_request(@request), message: '已排期' }
          else
            render json: { error: '当前状态无法排期' }, status: :unprocessable_entity
          end
        end
        
        # PATCH /api/v1/inspection/requests/:id/complete
        def complete
          if @request.may_complete?
            @request.complete!
            render json: { data: serialize_request(@request), message: '已完成' }
          else
            render json: { error: '当前状态无法完成' }, status: :unprocessable_entity
          end
        end
        
        # PATCH /api/v1/inspection/requests/:id/cancel
        def cancel
          if @request.may_cancel?
            @request.cancel!
            render json: { data: serialize_request(@request), message: '已取消' }
          else
            render json: { error: '当前状态无法取消' }, status: :unprocessable_entity
          end
        end
        
        private
        
        def set_request
          @request = ::Inspection::Request.find(params[:id])
        end
        
        def serialize_request(request)
          {
            id: request.id,
            order_number: request.order_number,
            style_number: request.style_number,
            quantity: request.quantity,
            status: request.status,
            status_label: request.status_label,
            inspection_type: request.inspection_type,
            requested_date: request.requested_date,
            result: request.result,
            remarks: request.remarks,
            supplier: request.supplier ? { id: request.supplier.id, name: request.supplier.name } : nil,
            product: request.product ? { id: request.product.id, name: request.product.name, product_code: request.product.product_code } : nil,
            items: request.items.map { |item| serialize_item(item) },
            can_schedule: request.may_schedule?,
            can_complete: request.may_complete?,
            can_cancel: request.may_cancel?,
            created_at: request.created_at,
            updated_at: request.updated_at
          }
        end
        
        def serialize_item(item)
          {
            id: item.id,
            order_number: item.order_number,
            style_number: item.style_number,
            quantity: item.quantity,
            inspection_level: item.inspection_level,
            aql_level: item.aql_level,
            sample_size: item.sample_size
          }
        end
      end
    end
  end
end
