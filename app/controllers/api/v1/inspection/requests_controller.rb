module Api
  module V1
    module Inspection
      class RequestsController < BaseController
        before_action :set_request, only: [:show, :schedule, :cancel]
        before_action :require_supplier!, only: [:create]
        before_action :require_qc_or_admin!, only: [:schedule]

        INSPECTION_TYPES = %w[中期检查 尾期检查 首件检查 过程检查].freeze

        # GET /api/v1/inspection/requests/new_options
        def new_options
          render json: {
            data: {
              suppliers: Supplier.order(:name).map { |s| { id: s.id, name: s.name } },
              products: Product.order(:name).map { |p| { id: p.id, name: p.name } },
              inspection_types: INSPECTION_TYPES,
              inspection_levels: AqlCalculator::INSPECTION_LEVELS.map { |l| { value: l, label: AqlCalculator::INSPECTION_LEVEL_LABELS[l] } },
              aql_levels: AqlCalculator::AQL_LEVELS
            }
          }
        end

        # GET /api/v1/inspection/requests
        def index
          requests = ::Inspection::Request.includes(:supplier, :product, :items)

          # 供应商只能看到自己的验货申请
          if current_user.supplier?
            requests = requests.where(supplier_id: current_user.supplier_id)
          end

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
          # 供应商只能查看自己的验货申请
          if current_user.supplier? && @request.supplier_id != current_user.supplier_id
            render json: { error: '无权查看此验货申请' }, status: :forbidden
            return
          end
          render json: { data: serialize_request(@request) }
        end

        # POST /api/v1/inspection/requests
        def create
          @request = ::Inspection::Request.new(request_params)
          @request.created_by = current_user
          # 供应商创建申请时强制绑定自己的供应商ID
          @request.supplier_id = current_user.supplier_id if current_user.supplier?

          if @request.save
            render json: { data: serialize_request(@request), message: '验货申请创建成功' }, status: :created
          else
            render json: { error: @request.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/inspection/requests/:id/schedule
        def schedule
          if @request.may_schedule?
            @request.schedule!
            render json: {
              data: serialize_request(@request),
              message: '已排期，请创建验货记录',
              redirect: "records/new?request_id=#{@request.id}"
            }
          else
            render json: { error: '当前状态无法排期' }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/inspection/requests/:id/cancel
        def cancel
          # 供应商只能取消自己的申请，QC/Admin可以取消任何申请
          if current_user.supplier? && @request.supplier_id != current_user.supplier_id
            render json: { error: '无权取消此验货申请' }, status: :forbidden
            return
          end

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

        def require_supplier!
          unless current_user.supplier? || current_user.admin?
            render json: { error: '只有供应商可以创建验货申请' }, status: :forbidden
          end
        end

        def require_qc_or_admin!
          unless current_user.inspector?
            render json: { error: '只有QC可以执行此操作' }, status: :forbidden
          end
        end

        def request_params
          params.require(:inspection_request).permit(
            :product_id, :supplier_id, :factory_id,
            :order_number, :style_number, :quantity,
            :requested_date, :inspection_type,
            :remarks,
            items_attributes: [:id, :order_number, :style_number, :quantity, :inspection_level, :aql_level, :_destroy]
          )
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
            remarks: request.remarks,
            supplier: request.supplier ? { id: request.supplier.id, name: request.supplier.name } : nil,
            product: request.product ? { id: request.product.id, name: request.product.name, product_code: request.product.product_code } : nil,
            items: request.items.map { |item| serialize_item(item) },
            can_schedule: request.may_schedule?,
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
