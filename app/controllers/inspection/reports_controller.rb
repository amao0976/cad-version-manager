module Inspection
  class ReportsController < BaseController
    include Pagy::Backend

    before_action :set_record, except: [:index]
    before_action :set_report, only: [:show, :edit, :update, :destroy, :complete, :reopen, :export_excel, :export_pdf, :remove_image]

    def index
      scope = Report.includes(inspection_record: [:product, :supplier, :factory])
                    .order(created_at: :desc)
      scope = scope.joins(:inspection_record).where(inspection_records: { result: params[:result] }) if params[:result].present?
      if params[:keyword].present?
        kw = "%#{params[:keyword]}%"
        scope = scope.joins(:inspection_record).where(
          "inspection_records.order_no LIKE :kw OR inspection_records.reference_no LIKE :kw OR inspection_records.supplier_name LIKE :kw",
          kw: kw
        )
      end
      @pagy, @reports = pagy(scope, limit: 10)
    end

    def show
    end

    def new
      if @record.report.present?
        redirect_to inspection_record_report_path(@record), notice: '该记录已有报告'
        return
      end
      @report = Report.new(inspection_id: @record.id)
      load_form_data
    end

    def create
      if @record.report.present?
        redirect_to inspection_record_report_path(@record), notice: '该记录已有报告'
        return
      end
      @report = Report.new(report_params)
      @report.inspection_id = @record.id
      if @report.save
        attach_images
        redirect_to inspection_record_report_path(@record), notice: '验货报告创建成功'
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_form_data
    end

    def update
      if @report.update(report_params)
        attach_images
        redirect_to inspection_record_report_path(@record), notice: '验货报告更新成功'
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @report.destroy
      redirect_to inspection_record_path(@record), notice: '验货报告已删除'
    end

    def complete
      @report.complete!
      redirect_to inspection_record_report_path(@record), notice: '报告已标记为完成'
    end

    def reopen
      @report.reopen!
      redirect_to inspection_record_report_path(@record), notice: '报告已重新打开'
    end

    def export_excel
      axlsx = Axlsx::Package.new
      wb = axlsx.workbook
      wb.styles do |s|
        header_style = s.add_style bg_color: '2563EB', fg_color: 'FFFFFF', b: true, alignment: { horizontal: :center }
        wb.add_worksheet(name: 'Inspection Report') do |sheet|
          insp = @report.inspection_record

          sheet.add_row ['Inspection Report'], style: header_style
          sheet.merge_cells("A1:F1")
          [
            ['Week', insp.week, 'Date', insp.inspection_date, 'QC', insp.qc_name],
            ['Supplier', insp.supplier_name.to_s, 'Factory', insp.factory_name.to_s, 'Type', insp.inspection_type.to_s],
            ['Order No', insp.order_no.to_s, 'Reference', insp.reference_no.to_s, 'Qty', insp.order_quantity.to_s],
            ['Result', insp.result.to_s, 'Buyer', insp.buyer.to_s, 'Country', insp.country.to_s]
          ].each { |row| sheet.add_row row }

          sheet.add_row []
          sheet.add_row ['Product Details'], style: header_style
          [
            ['Style', @report.style_description.to_s, 'Color', @report.color.to_s],
            ['Material', @report.material_composition.to_s, 'Size Range', @report.size_range.to_s],
            ['Remarks', @report.product_remarks.to_s]
          ].each { |row| sheet.add_row row }

          if @report.size_columns.any?
            sheet.add_row []
            sheet.add_row ['Size Table'], style: header_style
            header1 = ['Measurement Point', 'Tolerance']
            @report.size_columns.each { |col| header1 += [col, 'Nominal', 'Actual', 'Result'] }
            sheet.add_row header1

            @report.size_rows.each do |row|
              row_data = [row['measurement_point'].to_s, "\u00B1#{row['tolerance']}"]
              @report.size_columns.each do |col|
                vals = (row['values'] || {})[col] || {}
                result = @report.pass_fail_for(row, col)
                result_text = result == 'pass' ? 'Pass' : result == 'fail' ? 'Fail' : ''
                row_data += [vals['nominal'].to_s, vals['actual'].to_s, result_text]
              end
              sheet.add_row row_data
            end
          end

          if @report.summary.present?
            sheet.add_row []
            sheet.add_row ['Summary'], style: header_style
            sheet.add_row [@report.summary]
          end
        end
      end

      send_data axlsx.to_stream.read,
                filename: "Inspection_Report_#{@record.order_no}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    def export_pdf
      pdf = InspectionReportPdfService.new(@report).generate
      send_data pdf,
                filename: "Inspection_Report_#{@record.order_no}.pdf",
                type: 'application/pdf'
    end

    def remove_image
      attachment = ActiveStorage::Attachment.find(params[:attachment_id])
      if attachment.record == @report
        attachment.purge
      end
      redirect_back(fallback_location: inspection_record_report_path(@record), notice: '图片已删除')
    end

    def import_size_template
      file = params[:file]
      unless file
        render json: { error: '请选择模板文件' }, status: :bad_request
        return
      end

      begin
        spreadsheet = Roo::Spreadsheet.open(file.path)
        sheet = spreadsheet.sheet(0)
        measurement_points = []
        (2..sheet.last_row).each do |i|
          mp = sheet.cell(i, 1).to_s.strip
          tol = sheet.cell(i, 2).to_s.strip
          next if mp.blank?
          measurement_points << { measurement_point: mp, tolerance: tol }
        end
        render json: { measurement_points: measurement_points }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    def download_size_template_sample
      axlsx = Axlsx::Package.new
      wb = axlsx.workbook
      wb.styles do |s|
        header_style = s.add_style bg_color: '2563EB', fg_color: 'FFFFFF', b: true, alignment: { horizontal: :center }
        wb.add_worksheet(name: 'Size Template') do |sheet|
          sheet.add_row ['Measurement Point', 'Tolerance'], style: header_style
          sheet.add_row ['Chest Width', '1']
          sheet.add_row ['Body Length', '1']
          sheet.add_row ['Shoulder Width', '0.5']
          sheet.add_row ['Sleeve Length', '1']
          sheet.add_row ['Hem Width', '1']
        end
      end
      send_data axlsx.to_stream.read,
                filename: 'size_template_sample.xlsx',
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    private

    def set_record
      @record = Record.find(params[:record_id])
    end

    def set_report
      @report = @record.report
      unless @report
        redirect_to new_inspection_record_report_path(@record), alert: '报告不存在'
      end
    end

    def report_params
      params.require(:inspection_report).permit(
        :style_description, :color, :material_composition,
        :size_range, :summary, :product_remarks, :size_table_json,
        product_overview_images: [],
        label_hangtag_images: [],
        rfid_images: [],
        defect_detail_images: []
      )
    end

    def load_form_data
      @size_columns = %w[order_number style_number quantity shipment_quantity]
      @templates = Report.template_list
    end

    def attach_images
      %i[product_overview_images label_hangtag_images rfid_images defect_detail_images].each do |category|
        files = params.dig(:inspection_report, category)
        next if files.blank?
        files = files.select(&:present?)
        @report.public_send(category).attach(files) if files.any?
      end
    end
  end
end
