module Inspection
  class RecordsController < BaseController
    include Pagy::Backend

    before_action :set_record, only: [:show, :edit, :update, :destroy, :new_report]

    def index
      scope = Record.includes(:product, :supplier, :factory, :inspection_request)
                    .order(inspection_date: :desc)
      scope = apply_filters(scope)
      @pagy, @records = pagy(scope, limit: 10)
    end

    def show
      @report = @record.report
    end

    def new
      @record = Record.new
      @record.product_id = params[:product_id] if params[:product_id].present?
      load_form_data
    end

    def create
      @record = Record.new(record_params)
      @record.product_id = params[:product_id] if params[:product_id].present?

      if @record.save
        @record.inspection_request&.schedule!
        redirect_to @record, notice: '验货记录创建成功'
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_form_data
    end

    def update
      if @record.update(record_params)
        redirect_to @record, notice: '验货记录更新成功'
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      redirect_to inspection_records_path, notice: '验货记录已删除'
    end

    def new_report
      if @record.report.present?
        redirect_to inspection_report_path(@record.report), notice: '该记录已有报告'
      else
        @report = Report.new(inspection_id: @record.id)
        load_form_data
      end
    end

    def export
      scope = Record.includes(:product, :supplier, :factory).order(created_at: :desc)
      scope = apply_filters(scope)

      axlsx = Axlsx::Package.new
      wb = axlsx.workbook
      wb.styles do |s|
        header_style = s.add_style bg_color: '2563EB', fg_color: 'FFFFFF', b: true, alignment: { horizontal: :center }
        wb.add_worksheet(name: '检验记录') do |sheet|
          headers = %w[周次 检验日期 QC 供应商 工厂 城市 订单号 款号 检验类型 订单数量 出货数量 主要缺陷 次要缺陷 拒收数量 检验结果 备注]
          sheet.add_row headers, style: header_style
          scope.find_each do |i|
            sheet.add_row [
              i.week, i.inspection_date.to_s, i.qc_name,
              i.supplier_name, i.factory_name, i.city,
              i.order_no, i.reference_no, i.inspection_type,
              i.order_quantity, i.shipment_quantity,
              i.major_defects, i.minor_defects, i.qty_rejected,
              i.result_label, i.comments
            ]
          end
        end
      end

      send_data axlsx.to_stream.read,
                filename: "检验记录_#{Time.current.strftime('%Y%m%d')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    def import
      file = params[:file]
      if file.blank?
        redirect_to inspection_records_path, alert: '请选择要上传的文件'
        return
      end

      begin
        spreadsheet = open_spreadsheet(file)
        count = 0
        2.upto(spreadsheet.last_row) do |i|
          row = spreadsheet.row(i)
          next if row.all?(&:blank?)

          attrs = {
            week: row[0],
            inspection_date: parse_date(row[1]),
            qc_name: row[2],
            supplier_name: row[3],
            factory_name: row[4],
            city: row[5],
            order_no: row[7],
            reference_no: row[8],
            inspection_type: row[9],
            order_quantity: row[10],
            shipment_quantity: row[11],
            major_defects: row[12],
            minor_defects: row[13],
            qty_rejected: row[14],
            result: row[15],
            comments: row[16]
          }

          supplier = Supplier.find_by(name: attrs[:supplier_name]) if attrs[:supplier_name].present?
          attrs[:supplier_id] = supplier.id if supplier

          record = Record.new(attrs)
          record.save!
          count += 1
        end
        redirect_to inspection_records_path, notice: "成功导入 #{count} 条验货记录"
      rescue => e
        redirect_to inspection_records_path, alert: "导入失败: #{e.message}"
      end
    end

    private

    def set_record
      @record = Record.find(params[:id])
    end

    def apply_filters(scope)
      scope = scope.where(product_id: params[:product_id]) if params[:product_id].present?
      scope = scope.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?
      scope = scope.where(result: params[:result]) if params[:result].present?
      scope = scope.where(inspection_type: params[:inspection_type]) if params[:inspection_type].present?
      if params[:keyword].present?
        kw = "%#{params[:keyword]}%"
        scope = scope.where(
          "order_no LIKE :kw OR reference_no LIKE :kw OR supplier_name LIKE :kw OR qc_name LIKE :kw",
          kw: kw
        )
      end
      scope
    end

    def load_form_data
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

    def record_params
      params.require(:inspection_record).permit(
        :product_id, :supplier_id, :factory_id, :inspection_request_id,
        :inspection_date, :order_no, :reference_no, :week,
        :order_quantity, :shipment_quantity, :requested_date,
        :inspection_type, :buyer, :set_name, :fabric_name,
        :qc_name, :major_defects, :minor_defects, :qty_rejected,
        :result, :rfid_checking, :chemical_test, :physical_test,
        :transport, :comments, :ps_comments, :color
      )
    end
  end
end
