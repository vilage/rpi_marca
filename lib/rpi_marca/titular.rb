module RpiMarca
  class Titular
    attr_reader :nome_razao_social, :pais, :uf

    def initialize(nome_razao_social:, pais:, uf:)
      @nome_razao_social = nome_razao_social
      @pais = pais
      @uf = uf
    end

    def self.parse(el)
      return unless el

      new(
        nome_razao_social: Helpers.get_attribute_value(el, 'nome-razao-social'),
        pais: Helpers.get_attribute_value(el, 'pais'),
        uf: Helpers.get_attribute_value(el, 'uf')
      )
    end
  end
end
