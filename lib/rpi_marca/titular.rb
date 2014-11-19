module RpiMarca
  class Titular
    private_class_method :new
    attr_reader :nome_razao_social, :pais, :uf

    def initialize(nome_razao_social, pais, uf)
      @nome_razao_social = nome_razao_social
      @pais = pais
      @uf = uf
    end

    def self.parse(el)
      return nil unless el

      new(
        Publicacao.get_attribute_value(el, "nome-razao-social"),
        Publicacao.get_attribute_value(el, "pais"),
        Publicacao.get_attribute_value(el, "uf")
      )
    end
  end
end
