class PriceCalculator
  def self.calculate(variant, price_date: Date.current)
    rule = PriceRule.match_for(variant)
    return nil unless rule

    weight = variant.effective_weight
    material = variant.material || variant.product&.main_material
    material_price = material ? material.price_on(price_date) : 0
    material_cost = weight * material_price
    aux_cost = 0
    total = (material_cost + aux_cost + rule.labor_cost) * rule.markup_rate
    total.round(2)
  end
end
