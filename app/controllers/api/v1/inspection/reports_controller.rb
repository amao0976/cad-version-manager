module Api
  module V1
    module Inspection
      class ReportsController < BaseController
        before_action :set_report, only: [:show, :complete, :reopen, :upload_image, :remove_image]
        
        # GET /api/v1/inspection/reports/:id
        def show
          render json: { data: serialize_report(@report) }
        end
        
        # PATCH /api/v1/inspection/reports/:id/complete
        def complete
          if @report.can_complete?
            @report.complete!
            render json: { data: serialize_report(@report), message: '报告已完成' }
          else
            render json: { error: '当前状态无法完成' }, status: :unprocessable_entity
          end
        end
        
        # PATCH /api/v1/inspection/reports/:id/reopen
        def reopen
          if @report.can_reopen?
            @report.reopen!
            render json: { data: serialize_report(@report), message: '报告已重新打开' }
          else
            render json: { error: '当前状态无法重新打开' }, status: :unprocessable_entity
          end
        end
        
        # POST /api/v1/inspection/reports/:id/upload_image
        def upload_image
          category = params[:category] # product_overview, label_hangtag, rfid, defect_detail
          
          unless params[:image].present?
            render json: { error: '请上传图片' }, status: :bad_request
            return
          end
          
          image_category = "#{category}_images".to_sym
          
          unless @report.respond_to?(image_category)
            render json: { error: '无效的图片类别' }, status: :unprocessable_entity
            return
          end
          
          @report.public_send(image_category).attach(params[:image])
          
          render json: { 
            data: serialize_report(@report.reload), 
            message: '图片上传成功' 
          }
        end
        
        # DELETE /api/v1/inspection/reports/:id/remove_image
        def remove_image
          attachment = ActiveStorage::Attachment.find(params[:attachment_id])
          
          unless attachment && attachment.record == @report
            render json: { error: '图片不存在' }, status: :not_found
            return
          end
          
          attachment.purge
          
          render json: { 
            data: serialize_report(@report.reload), 
            message: '图片已删除' 
          }
        end
        
        private
        
        def set_report
          @report = ::Inspection::Report.find(params[:id])
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
            product_overview_images: report.product_overview_images.map { |img| url_for(img) },
            label_hangtag_images: report.label_hangtag_images.map { |img| url_for(img) },
            rfid_images: report.rfid_images.map { |img| url_for(img) },
            defect_detail_images: report.defect_detail_images.map { |img| url_for(img) },
            inspection_record: report.inspection_record ? { id: report.inspection_record.id, order_no: report.inspection_record.order_no } : nil,
            created_at: report.created_at,
            updated_at: report.updated_at
          }
        end
      end
    end
  end
end
