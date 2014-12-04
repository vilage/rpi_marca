module RpiMarca
  class Helpers
    def self.get_attribute_value(element, attr)
      return nil unless element

      value = element[attr]
      value unless value.nil? || value.empty?
    end

    def self.get_element_value(element)
      return element.text unless element.nil? || element.text == ''
    end

    def self.parse_date(value)
      Date.strptime(value, '%d/%m/%Y') if value
    end
  end
end
