module Inspection
  class RequestsController < BaseController
    include Pagy::Backend

    before_action :set_request, only: [:show, :edit, :update, :destroy, :schedule, :complete, :cancel, :review, :remove_screenshot, :new_inspection]

    def index
      scope = Request.includes(:supplier, :factory, :product, :created_by, :items)
                        .order(created_at: :desc)
      scope = apply_filters(scope)
      @pagy, @requests = pagy(scope, limit: 10)
    end

    def calendar
      @view_mode = params[:view] || 'month'
      @current_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

      case @view_mode
      when 'week'
        @start_date = @current_date.beginning_of_week(:sunday)
        @end_date = @start_date + 6.days
      else
        @start_date = @current_date.beginning_of_month
        @end_date = @current_date.end_of_month
      end

      @requests = Request.includes(:supplier, :product)
                        .where(requested_date: @start_date..@end_date)
                        .where.not(status: 'cancelled')
                        .order(:requested_date)

      respond_to do |format|
        format.html
        format.json { render json: @requests.map { |r| serialize_calendar_json(r) } }
      end
    end

    def show
      @items = @request.items.order(created_at: :asc)
    end

    def new
      @request = Request.new
      @request.items.build
      load_form_data
    end

    def create
      @request = Request.new(request_params)
      @request.created_by = current_user

      if @request.save
        redirect_to @request, notice: '验货申请创建成功'
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_form_data
    end

    def update
      if @request.update(request_params)
        redirect_to @request, notice: '验货申请更新成功'
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @request.destroy
      redirect_to inspection_requests_path, notice: '验货申请已删除'
    end

    def schedule
      @request.schedule!
      redirect_to @request, notice: '验货申请已排期'
    end

    def complete
      @request.complete!
      redirect_to @request, notice: '验货申请已完成'
    end

    def cancel
      @request.cancel!
      redirect_to @request, notice: '验货申请已取消'
    end

    def review
      if @request.update(review_params)
        attach_screenshots
        redirect_to @request, notice: '审核已更新'
      else
        redirect_to @request, alert: '审核更新失败'
      end
    end

    def remove_screenshot
      attachment = ActiveStorage::Attachment.find(params[:attachment_id])
      if attachment.record == @request
        attachment.purge
      end
      redirect_to @request, notice: '截图已删除'
    end

    def new_inspection
      unless @request.can_create_inspection?
        redirect_to @request, alert: '需要审核结果为PASS并上传审批截图后才能创建验货记录'
        return
      end

      first_item = @request.items.first

      @record = Record.new(
        inspection_request_id: @request.id,
        product_id: @request.product_id,
        supplier_id: @request.supplier_id,
        factory_id: @request.factory_id,
        order_no: first_item&.order_number,
        reference_no: first_item&.style_number,
        order_quantity: @request.total_quantity,
        requested_date: @request.requested_date,
        inspection_type: @request.inspection_type,
        qc_name: current_user.name
      )

      load_record_form_data
      render template: 'inspection/records/new'
    end

    def export
      scope = Request.includes(:supplier, :factory, :product, :items).order(created_at: :desc)
      scope = apply_filters(scope)

      axlsx = Axlsx::Package.new
      wb = axlsx.workbook
      wb.styles do |s|
        header_style = s.add_style bg_color: '2563EB', fg_color: 'FFFFFF', b: true, alignment: { horizontal: :center }
        wb.add_worksheet(name: '验货申请') do |sheet|
          headers = %w[订单号 款号 数量 检验类型 申请日期 供应商 工厂 状态 备注]
          sheet.add_row headers, style: header_style
          scope.find_each do |r|
            sheet.add_row [
              r.order_number, r.style_number, r.quantity, r.inspection_type,
              r.requested_date.to_s, r.supplier_name, r.factory_name,
              r.status_label, r.remarks
            ]
          end
        end
      end

      send_data axlsx.to_stream.read,
                filename: "验货申请_#{Time.current.strftime('%Y%m%d')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    def import
      file = params[:file]
      if file.blank?
        redirect_to inspection_requests_path, alert: '请选择要上传的文件'
        return
      end

      begin
        spreadsheet = open_spreadsheet(file)
        count = 0
        2.upto(spreadsheet.last_row) do |i|
          row = spreadsheet.row(i)
          next if row.all?(&:blank?)

          supplier_name = row[5].to_s.strip
          supplier = Supplier.find_by(name: supplier_name) if supplier_name.present?

          attrs = {
            order_number: row[0], style_number: row[1], quantity: row[2],
            inspection_type: row[3], requested_date: parse_date(row[4]),
            supplier_id: supplier&.id, supplier_name: supplier_name,
            factory_name: row[6], status: 'pending', remarks: row[8]
          }
          Request.create!(attrs)
          count += 1
        end
        redirect_to inspection_requests_path, notice: "成功导入 #{count} 条验货申请"
      rescue => e
        redirect_to inspection_requests_path, alert: "导入失败: #{e.message}"
      end
    end

    private

    def set_request
      @request = Request.find(params[:id])
    end

    def apply_filters(scope)
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?
      if params[:keyword].present?
        kw = "%#{params[:keyword]}%"
        scope = scope.left_joins(:items)
                     .where("inspection_request_items.order_number LIKE :kw OR inspection_request_items.style_number LIKE :kw OR inspection_requests.supplier_name LIKE :kw", kw: kw)
                     .distinct
      end
      scope
    end

    def load_form_data
      @suppliers = Supplier.order(:name)
      @factories = @request.supplier&.factories&.order(:name) || []
      @products = Product.order(:name)
    end

    def load_record_form_data
      @suppliers = Supplier.order(:name)
      @factories = @record.supplier&.factories&.order(:name) || []
      @products = Product.order(:name)
      @requests = Request.order(:order_number)
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename).downcase
      when '.csv' then Roo::CSV.new(file.path)
      when '.xls' then Roo::Excel.new(file.path)
      when '.xlsx' then Roo::Excelx.new(file.path)
      else raise '不支持的文件格式'
      end
    end

    def parse_date(value)
      return nil if value.blank?
      case value
      when Date then value
      when Numeric then Date.new(1899, 12, 30) + value.to_i
      else Date.parse(value.to_s) rescue nil
      end
    end

    helper_method :serialize_calendar_json

    def serialize_calendar_json(request)
      {
        id: request.id,
        title: "#{request.order_number} - #{request.style_number}",
        start: request.requested_date.to_s,
        end: request.requested_date.to_s,
        allDay: true,
        color: request.status == 'scheduled' ? '#2563eb' : '#f59e0b',
        status: request.status,
        status_label: request.status_label,
        inspection_type: request.inspection_type,
        supplier_name: request.supplier_name || request.supplier&.name,
        product_name: request.product&.name,
        quantity: request.quantity,
        remarks: request.remarks
      }
    end

    def request_params
      params.require(:inspection_request).permit(
        :product_id, :supplier_id, :factory_id,
        :order_number, :style_number, :quantity,
        :requested_date, :inspection_type,
        :remarks, :ps_comments,
        items_attributes: [:id, :order_number, :style_number, :quantity, :inspection_level, :aql_level, :_destroy]
      )
    end

    def review_params
      params.require(:inspection_request).permit(:ps_comments, :result)
    end

    def attach_screenshots
      files = params.dig(:inspection_request, :approval_screenshots)
      return if files.blank?
      files = files.select(&:present?)
      @request.approval_screenshots.attach(files) if files.any?
    end
  end
end
