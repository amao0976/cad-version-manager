module Api
  module V1
    module Inspection
      class ReportsController < BaseController
        before_action :set_report, only: [:show, :complete, :reopen, :upload_image, :remove_image, :update_notes]
        before_action :require_qc_or_admin!, only: [:complete, :reopen, :upload_image, :remove_image, :update_notes]

        IMAGE_CATEGORIES = {
          'product_overview' => '产品外观',
          'label_hangtag' => '标签吊牌',
          'rfid' => 'RFID',
          'defect_detail' => '缺陷细节'
        }.freeze

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
        # 参数: category (product_overview/label_hangtag/rfid/defect_detail), image (文件)
        def upload_image
          category = params[:category] || params.dig(:inspection_report, :category)

          unless category.present?
            render json: { error: '请指定图片类别' }, status: :bad_request
            return
          end

          image_file = params[:image] || params.dig(:inspection_report, :image)

          unless image_file.present?
            render json: { error: '请上传图片' }, status: :bad_request
            return
          end

          image_category = "#{category}_images".to_sym

          unless @report.respond_to?(image_category)
            render json: { error: "无效的图片类别: #{category}，可选: #{IMAGE_CATEGORIES.keys.join(', ')}" }, status: :unprocessable_entity
            return
          end

          begin
            @report.public_send(image_category).attach(image_file)
            render json: {
              data: serialize_report(@report.reload),
              message: '图片上传成功'
            }
          rescue => e
            render json: { error: "图片上传失败: #{e.message}" }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/inspection/reports/:id/remove_image
        def remove_image
          attachment = ActiveStorage::Attachment.find_by(id: params[:attachment_id])

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

        def require_qc_or_admin!
          unless current_user.inspector?
            render json: { error: '只有QC可以执行此操作' }, status: :forbidden
          end
        end

        def serialize_report(report)
          {
            id: report.id,
            status: report.status,
            status_label: report.status_label,
            inspection_id: report.inspection_id,
            inspection_record: report.inspection_record ? {
              id: report.inspection_record.id,
              order_no: report.inspection_record.order_no,
              reference_no: report.inspection_record.reference_no
            } : nil,
            image_categories: IMAGE_CATEGORIES.transform_values { |label|
              { label: label, count: 0 }
            },
            images: {
              product_overview: report.product_overview_images.map { |img| { id: img.id, url: url_for(img) } },
              label_hangtag: report.label_hangtag_images.map { |img| { id: img.id, url: url_for(img) } },
              rfid: report.rfid_images.map { |img| { id: img.id, url: url_for(img) } },
              defect_detail: report.defect_detail_images.map { |img| { id: img.id, url: url_for(img) } }
            },
            created_at: report.created_at,
            updated_at: report.updated_at
          }
        end
      end
    end
  end
end
