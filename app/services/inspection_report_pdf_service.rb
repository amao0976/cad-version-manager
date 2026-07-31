class InspectionReportPdfService
  require "prawn"
  require "prawn/table"

  def initialize(report)
    @report = report
    @inspection = report.inspection_record
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: [40, 40, 40, 40])
    add_header(pdf)
    add_inspection_info(pdf)
    add_product_details(pdf)
    add_size_table(pdf) if @report.size_columns.any?
    add_summary(pdf) if @report.summary.present?
    pdf.render
  end

  private

  def add_header(pdf)
    pdf.text "Inspection Report", size: 20, style: :bold, align: :center
    pdf.move_down 10
    pdf.text "Date: #{Date.today.strftime('%Y-%m-%d')}", size: 10, align: :center
    pdf.move_down 20
  end

  def add_inspection_info(pdf)
    data = [
      ["Week", @inspection.week.to_s, "Date", @inspection.inspection_date.to_s],
      ["Supplier", @inspection.supplier_name.to_s, "Factory", @inspection.factory_name.to_s],
      ["Order No", @inspection.order_no.to_s, "Reference", @inspection.reference_no.to_s],
      ["Quantity", @inspection.order_quantity.to_s, "Shipment", @inspection.shipment_quantity.to_s],
      ["Result", @inspection.result.to_s, "QC", @inspection.qc_name.to_s]
    ]

    pdf.table(data, header: false, cell_style: { size: 9, padding: 5 }) do |t|
      t.cells.borders = [:left, :right]
      t.rows(0).borders = [:left, :right, :top]
      t.rows(-1).borders = [:left, :right, :bottom]
      t.column(0).width = 80
      t.column(2).width = 80
    end
    pdf.move_down 15
  end

  def add_product_details(pdf)
    pdf.text "Product Details", size: 14, style: :bold
    pdf.move_down 5

    data = [
      ["Style", @report.style_description.to_s, "Color", @report.color.to_s],
      ["Material", @report.material_composition.to_s, "Size Range", @report.size_range.to_s]
    ]

    pdf.table(data, header: false, cell_style: { size: 9, padding: 5 }) do |t|
      t.cells.borders = []
      t.column(0).width = 80
      t.column(2).width = 80
    end
    pdf.move_down 10

    if @report.product_remarks.present?
      pdf.text "Remarks: #{@report.product_remarks}", size: 9
      pdf.move_down 10
    end
  end

  def add_size_table(pdf)
    pdf.text "Size Table", size: 14, style: :bold
    pdf.move_down 5

    header_row = ["Measurement Point", "Tolerance"]
    @report.size_columns.each do |col|
      header_row += [col, "Nominal", "Actual", "Result"]
    end

    table_data = [header_row]
    @report.size_rows.each do |row|
      row_data = [row["measurement_point"].to_s, "\u00B1#{row['tolerance']}"]
      @report.size_columns.each do |col|
        vals = (row["values"] || {})[col] || {}
        result = @report.pass_fail_for(row, col)
        result_text = result == "pass" ? "\u2713 Pass" : result == "fail" ? "\u2717 Fail" : ""
        row_data += [vals["nominal"].to_s, vals["actual"].to_s, result_text]
      end
      table_data << row_data
    end

    pdf.table(table_data, header: true, cell_style: { size: 8, padding: 3 }) do |t|
      t.row_colors = [nil, "F5F5F5"]
      t.columns(0..-1).borders = [:left, :right]
      t.rows(0).borders = [:top, :left, :right, :bottom]
      t.rows(-1).borders = [:bottom, :left, :right]
    end
    pdf.move_down 10
  end

  def add_summary(pdf)
    pdf.text "Summary", size: 14, style: :bold
    pdf.move_down 5
    pdf.text @report.summary, size: 10
  end
end
