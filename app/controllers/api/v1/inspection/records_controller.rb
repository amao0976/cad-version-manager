module Api
  module V1
    module Inspection
      class RecordsController < BaseController
        before_action :set_record, only: [:show, :report, :create_report]
        
        # GET /api/v1/inspection/records
        def index
          records = ::Inspection::Record.includes(:product, :supplier, :request, :report)
          
          if params[:status].present?
            records = records.joins(:request).where(inspection_requests: { status: params[:status] })
          end
          
          if params[:result].present?
            records = records.where(result: params[:result])
          end
          
          if params[:keyword].present?
            keyword = "%#{params[:keyword]}%"
            records = records.where(
              "order_no LIKE :kw OR reference_no LIKE :kw",
              kw: keyword
            )
          end
          
          records = records.order(created_at: :desc)
          
          paginated = paginate(records)
          render json: {
            data: paginated[:data].map { |r| serialize_record(r) },
            meta: paginated[:meta]
          }
        end
        
        # GET /api/v1/inspection/records/:id
        def show
          render json: { data: serialize_record(@record) }
        end
        
        # GET /api/v1/inspection/records/pending
        def pending
          records = ::Inspection::Record.includes(:product, :supplier)
            .joins(:request)
            .where(inspection_requests: { status: [:pending, :scheduled] })
            .where(result: nil)
            .order(created_at: :desc)
          
          render json: { data: records.map { |r| serialize_record(r) } }
        end
        
        # GET /api/v1/inspection/records/:id/report
        def report
          if @record.report
            render json: { data: serialize_report(@record.report) }
          else
            render json: { data: nil, message: '暂无报告' }
          end
        end
        
        # POST /api/v1/inspection/records/:id/create_report
        def create_report
          if @record.report.present?
            render json: { error: '该记录已有报告' }, status: :unprocessable_entity
            return
          end
          
          @record.report = ::Inspection::Report.new(
            inspection_id: @record.id,
            status: 'draft'
          )
          
          if @record.save
            render json: { data: serialize_report(@record.report), message: '报告创建成功' }, status: :created
          else
            render json: { error: @record.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end
        
        private
        
        def set_record
          @record = ::Inspection::Record.find(params[:id])
        end
        
        def serialize_record(record)
          {
            id: record.id,
            order_no: record.order_no,
            reference_no: record.reference_no,
            inspection_date: record.inspection_date,
            request_date: record.requested_date,
            inspection_type: record.inspection_type,
            result: record.result,
            major_defects: record.major_defects,
            minor_defects: record.minor_defects,
            qty_rejected: record.qty_rejected,
            order_quantity: record.order_quantity,
            shipment_quantity: record.shipment_quantity,
            comments: record.comments,
            product: record.product ? { id: record.product.id, name: record.product.name, product_code: record.product.product_code, cover_image: record.product.cover_image&.image&.url } : nil,
            supplier: record.supplier ? { id: record.supplier.id, name: record.supplier.name } : nil,
            request: record.request ? { id: record.request.id, status: record.request.status, status_label: record.request.status_label } : nil,
            has_report: record.report.present?,
            created_at: record.created_at,
            updated_at: record.updated_at
          }
        end
        
        def serialize_report(report)
          {
            id: report.id,
            status: report.status,
            style_description: report.style_description,
            color: report.color,
            material_composition: report.material_composition,
            size_range: report.size_range,
            summary: report.summary,
            product_remarks: report.product_remarks,
            size_table: report.size_table,
            has_images: report.product_overview_images.attached?,
            created_at: report.created_at,
            updated_at: report.updated_at
          }
        end
      end
    end
  end
end
