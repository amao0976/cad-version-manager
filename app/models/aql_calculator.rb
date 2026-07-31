module AqlCalculator
  # ISO 2859-1 / ANSI/ASQ Z1.4 Sampling Tables

  LOT_SIZE_RANGES = [
    { min: 2,       max: 8,       l1: "A", l2: "A", l3: "B" },
    { min: 9,       max: 15,      l1: "A", l2: "B", l3: "C" },
    { min: 16,      max: 25,      l1: "B", l2: "C", l3: "D" },
    { min: 26,      max: 50,      l1: "C", l2: "D", l3: "E" },
    { min: 51,      max: 90,      l1: "D", l2: "E", l3: "F" },
    { min: 91,      max: 150,     l1: "E", l2: "F", l3: "G" },
    { min: 151,     max: 280,     l1: "F", l2: "G", l3: "H" },
    { min: 281,     max: 500,     l1: "G", l2: "H", l3: "J" },
    { min: 501,     max: 1200,    l1: "H", l2: "J", l3: "K" },
    { min: 1201,    max: 3200,    l1: "J", l2: "K", l3: "L" },
    { min: 3201,    max: 10000,   l1: "K", l2: "L", l3: "M" },
    { min: 10001,   max: 35000,   l1: "L", l2: "M", l3: "N" },
    { min: 35001,   max: 150000,  l1: "M", l2: "N", l3: "P" },
    { min: 150001,  max: 500000,  l1: "N", l2: "P", l3: "Q" },
    { min: 500001,  max: Float::INFINITY, l1: "P", l2: "Q", l3: "Q" },
  ].freeze

  SAMPLE_SIZES = {
    "A" => 2,    "B" => 3,    "C" => 5,    "D" => 8,
    "E" => 13,   "F" => 20,   "G" => 32,   "H" => 50,
    "J" => 80,   "K" => 125,  "L" => 200,  "M" => 315,
    "N" => 500,  "P" => 800,  "Q" => 1250
  }.freeze

  AQL_TABLE = {
    "1.0" => {
      "A" => [0, 1], "B" => [0, 1], "C" => [0, 1], "D" => [0, 1],
      "E" => [0, 1], "F" => [0, 1], "G" => [1, 2], "H" => [1, 2],
      "J" => [2, 3], "K" => [3, 4], "L" => [5, 6], "M" => [7, 8],
      "N" => [10, 11], "P" => [10, 11], "Q" => [10, 11]
    },
    "1.5" => {
      "A" => [0, 1], "B" => [0, 1], "C" => [0, 1], "D" => [0, 1],
      "E" => [0, 1], "F" => [1, 2], "G" => [1, 2], "H" => [2, 3],
      "J" => [3, 4], "K" => [5, 6], "L" => [7, 8], "M" => [10, 11],
      "N" => [14, 15], "P" => [14, 15], "Q" => [14, 15]
    },
    "2.5" => {
      "A" => [0, 1], "B" => [0, 1], "C" => [0, 1], "D" => [0, 1],
      "E" => [1, 2], "F" => [1, 2], "G" => [2, 3], "H" => [3, 4],
      "J" => [5, 6], "K" => [7, 8], "L" => [10, 11], "M" => [14, 15],
      "N" => [21, 22], "P" => [21, 22], "Q" => [21, 22]
    },
    "4.0" => {
      "A" => [0, 1], "B" => [0, 1], "C" => [1, 2], "D" => [1, 2],
      "E" => [1, 2], "F" => [2, 3], "G" => [3, 4], "H" => [5, 6],
      "J" => [7, 8], "K" => [10, 11], "L" => [14, 15], "M" => [21, 22],
      "N" => [21, 22], "P" => [21, 22], "Q" => [21, 22]
    }
  }.freeze

  AQL_LEVELS = %w[0.65 1.0 1.5 2.5 4.0 6.5].freeze
  INSPECTION_LEVELS = %w[I II III].freeze
  INSPECTION_LEVEL_LABELS = { "I" => "特殊放宽", "II" => "正常", "III" => "加严" }.freeze

  module_function

  def code_letter(lot_size, inspection_level = "II")
    return nil if lot_size.nil? || lot_size < 1
    range = LOT_SIZE_RANGES.find { |r| lot_size >= r[:min] && lot_size <= r[:max] }
    return nil unless range
    case inspection_level
    when "I"  then range[:l1]
    when "III" then range[:l3]
    else range[:l2]
    end
  end

  def sample_size_for(code_letter)
    SAMPLE_SIZES[code_letter]
  end

  def calculate(lot_size, aql_level = "2.5", inspection_level = "II")
    cl = code_letter(lot_size, inspection_level)
    return { code_letter: nil, sample_size: nil, accept_qty: nil, reject_qty: nil } unless cl

    ss = SAMPLE_SIZES[cl]
    aql_data = AQL_TABLE[aql_level.to_s] || AQL_TABLE["2.5"]
    ac, re = aql_data[cl] || [0, 1]

    {
      code_letter: cl,
      sample_size: ss,
      accept_qty: ac,
      reject_qty: re
    }
  end
end
