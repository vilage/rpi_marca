module RpiMarca
  class Owner
    attr_reader :name, :country, :state

    def initialize(name:, country:, state:)
      @name = name
      @country = country
      @state = state
    end

    def self.parse(el)
      return unless el

      new(
        name: Helpers.get_attribute_value(el, 'nome-razao-social'),
        country: Helpers.get_attribute_value(el, 'pais'),
        state: Helpers.get_attribute_value(el, 'uf')
      )
    end
  end
end
