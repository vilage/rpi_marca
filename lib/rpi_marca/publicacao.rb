require "rpi_marca/helpers"
require "rpi_marca/titular"
require "rpi_marca/protocolo"
require "rpi_marca/despacho"
require "rpi_marca/ncl"
require "rpi_marca/classe_nacional"
require "rpi_marca/classe_vienna"
require "rpi_marca/prioridade_unionista"
require "rpi_marca/sobrestador"
require "nokogiri"

module RpiMarca
  class Publicacao
    attr_reader :processo
    attr_reader :despachos
    attr_reader :deposito
    attr_reader :concessao
    attr_reader :vigencia
    attr_reader :ncl
    attr_reader :classe_nacional
    attr_reader :classe_vienna
    attr_reader :titulares
    attr_reader :marca
    attr_reader :apresentacao
    attr_reader :natureza
    attr_reader :procurador
    attr_reader :apostila
    attr_reader :sobrestadores
    attr_reader :prioridades

    NATUREZA_NORMALIZACAO = {
      "Certific." => "Certificação"
    }

    def initialize(publicacao)
      @despachos = []
      @titulares = []
      @sobrestadores = []
      @prioridades = []

      element = validate_and_parse_publicacao(publicacao)
      parse_xml_elements(element)
    end

    protected

    def validate_and_parse_publicacao(element)
      element =
        if element.is_a? Nokogiri::XML::Element
          element
        elsif element.is_a? String
          Nokogiri::XML(element).at_xpath("//processo")
        else
          fail ParseError, "Publicação em formato inválido: #{element.class}"
        end

      fail ParseError if element.name != "processo"

      element
    end

    def parse_xml_elements(publicacao)
      parse_processo(publicacao)

      publicacao.elements.each do |el|
        normalized_element_name = el.name.gsub("-", "_")
        parse_method = "parse_#{normalized_element_name}".to_sym

        fail ParseError unless respond_to?(parse_method, true)

        __send__(parse_method, el)
      end
    end

    def parse_processo(el)
      @processo = Helpers.get_attribute_value(el, "numero") or fail ParseError
      @deposito = Helpers.parse_date(Helpers.get_attribute_value(el, "data-deposito"))

      @concessao = Helpers.parse_date(Helpers.get_attribute_value(el, "data-concessao"))
      @vigencia = Helpers.parse_date(Helpers.get_attribute_value(el, "data-vigencia"))

      fail ParseError if @concessao && @vigencia.nil?
      fail ParseError if @vigencia && @concessao.nil?
    end

    def parse_despachos(el)
      el = el.elements
      fail ParseError if el.empty?

      @despachos = el.map { |despacho| Despacho.parse(despacho) }
    end

    def parse_procurador(el)
      @procurador = Helpers.get_element_value(el)
    end

    def parse_titulares(el)
      @titulares = el.elements.map { |titular| Titular.parse(titular) }
    end

    def parse_sobrestadores(el)
      @sobrestadores = el.elements.map { |sobrestador| Sobrestador.parse(sobrestador) }
    end

    def parse_marca(el)
      @marca = Helpers.get_element_value(el.at_xpath(".//nome"))
      @apresentacao = Helpers.get_attribute_value(el, "apresentacao")
      @natureza = NATUREZA_NORMALIZACAO.fetch(Helpers.get_attribute_value(el, "natureza")) { |default| default }
    end

    def parse_classe_nice(el)
      @ncl = Ncl.parse(el)
    end

    def parse_classe_nacional(el)
      @classe_nacional = ClasseNacional.parse(el)
    end

    def parse_classes_vienna(el)
      @classe_vienna = ClasseVienna.parse(el)
    end

    def parse_prioridade_unionista(el)
      @prioridades = el.elements.map { |prioridade| PrioridadeUnionista.parse(prioridade) }
    end

    def parse_apostila(el)
      @apostila = Helpers.get_element_value(el)
    end
  end
end
