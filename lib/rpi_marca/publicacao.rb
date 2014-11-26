require "rpi_marca/titular"
require "rpi_marca/protocolo"
require "rpi_marca/despacho"
require "rpi_marca/ncl"
require "rpi_marca/classe_nacional"
require "rpi_marca/classe_logotipo"
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
    attr_reader :classe_logotipo
    attr_reader :titulares
    attr_reader :marca
    attr_reader :apresentacao
    attr_reader :natureza
    attr_reader :procurador
    attr_reader :apostila
    attr_reader :sobrestadores
    attr_reader :prioridades

    DESPACHOS_PROTOCOLO_NAO_OBRIGATORIO = [
      "IPAS005", "IPAS009", "IPAS024", "IPAS033", "IPAS029", "IPAS047",
      "IPAS091", "IPAS106", "IPAS112", "IPAS135", "IPAS136", "IPAS139",
      "IPAS142", "IPAS157", "IPAS158", "IPAS161", "IPAS289", "IPAS291",
      "IPAS304", "IPAS395", "IPAS402", "IPAS404", "IPAS409", "IPAS421",
      "IPAS423"
    ]

    NATUREZA_NORMALIZACAO = {
      "Certific." => "Certificação"
    }

    def initialize(publicacao)
      @publicacao =
        if publicacao.is_a? Nokogiri::XML::Element
          publicacao
        elsif publicacao.is_a? String
          Nokogiri::XML(publicacao).at_xpath("//processo")
        else
          raise ParseError, "Publicação em formato inválido: #{publicacao.class}"
        end

      raise ParseError if @publicacao.name != "processo"

      @despachos = []
      @titulares = []
      @sobrestadores = []
      @prioridades = []

      parse
    end

    def self.get_attribute_value(element, attr)
      return nil unless element

      value = element[attr]
      value unless value.nil? || value.empty?
    end

    def self.get_element_value(element)
      return element.text unless element.nil? || element.text == ""
    end

    def self.parse_date(value)
      Date.strptime(value, "%d/%m/%Y") if value
    end

    protected
    def parse
      parse_processo

      @publicacao.elements.each do |el|
        renamed = el.name.gsub("-", "_")
        parse_method = "parse_#{renamed}".to_sym
        __send__(parse_method, el) #if respond_to?(parse_method, true)
      end
    end

    def parse_processo
      @processo = Publicacao.get_attribute_value(@publicacao, "numero") or raise ParseError
      @deposito = Publicacao.parse_date(Publicacao.get_attribute_value(@publicacao, "data-deposito"))
      @concessao = Publicacao.parse_date(Publicacao.get_attribute_value(@publicacao, "data-concessao"))
      @vigencia = Publicacao.parse_date(Publicacao.get_attribute_value(@publicacao, "data-vigencia"))

      raise ParseError if @concessao && @vigencia.nil?
      raise ParseError if @vigencia && @concessao.nil?
    end

    def parse_despachos(el)
      el = el.elements
      raise ParseError if el.empty?

      @despachos = el.map do |despacho|
        codigo = Publicacao.get_attribute_value(despacho, "codigo") or raise ParseError
        nome = Publicacao.get_attribute_value(despacho, "nome") or raise ParseError

        Despacho.new(
          codigo: codigo,
          descricao: nome,
          complemento: Publicacao.get_element_value(despacho.at_xpath("texto-complementar")),
          protocolo: parse_protocolo(despacho.at_xpath("protocolo"), codigo)
        )
      end
    end

    def parse_procurador(el)
      @procurador = Publicacao.get_element_value(el)
    end

    def parse_titulares(el)
      el = el.elements
      el.each { |titular| @titulares << Titular.parse(titular) }
    end

    def parse_sobrestadores(el)
      @sobrestadores = el.elements.map do |sobrestador|
        Sobrestador.new(
          processo: Publicacao.get_attribute_value(sobrestador, "processo"),
          marca: Publicacao.get_attribute_value(sobrestador, "marca")
        )
      end
    end

    def parse_marca(el)
      @marca = Publicacao.get_element_value(el.at_xpath(".//nome"))
      @apresentacao = Publicacao.get_attribute_value(el, "apresentacao")
      @natureza = NATUREZA_NORMALIZACAO.fetch(Publicacao.get_attribute_value(el, "natureza")) { |default| default }
    end

    def parse_classe_nice(el)
      return unless el

      @ncl = Ncl.new(
        classe: Publicacao.get_attribute_value(el, "codigo"),
        edicao: Publicacao.get_attribute_value(el, "edicao").to_i,
        especificacao: Publicacao.get_element_value(el.at_xpath(".//especificacao"))
      )
    end

    def parse_classe_nacional(el)
      return unless el

      subclasses = el.xpath(".//sub-classe-nacional").map { |s| s["codigo"] }
      raise ParseError, "Classe nacional possui mais de 3 subclasses" if subclasses.length > 3

      @classe_nacional = ClasseNacional.new(
        classe: Publicacao.get_attribute_value(el, "codigo").to_i,
        subclasse1: subclasses[0].to_i,
        subclasse2: subclasses[1].to_i,
        subclasse3: subclasses[2].to_i,
        especificacao: Publicacao.get_element_value(el.at_xpath(".//especificacao")),
      )
    end

    def parse_classes_vienna(el)
      return unless el

      classes = el.xpath(".//classe-vienna").map { |s| s["codigo"] }
      raise ParseError, "Classe Vienna possui mais de 5 classes" if classes.length > 5

      @classe_logotipo = ClasseLogotipo.new(
        edicao: Publicacao.get_attribute_value(el, "edicao").to_i,
        classe1: classes[0],
        classe2: classes[1],
        classe3: classes[2],
        classe4: classes[3],
        classe5: classes[4]
      )
    end

    def parse_prioridade_unionista(el)
      @prioridades = el.elements.map do |prioridade|
        data_prioridade = Publicacao.parse_date(Publicacao.get_attribute_value(prioridade, "data"))
        raise ParseError, "Publicação unionista deve ter data da prioridade" unless data_prioridade

        PrioridadeUnionista.new(
          numero: Publicacao.get_attribute_value(prioridade, "numero"),
          data: data_prioridade,
          pais: Publicacao.get_attribute_value(prioridade, "pais")
        )
      end
    end

    def parse_apostila(el)
      @apostila = Publicacao.get_element_value(el)
    end

    def parse_protocolo(protocolo, codigo_despacho)
      return if protocolo.nil? && DESPACHOS_PROTOCOLO_NAO_OBRIGATORIO.include?(codigo_despacho)

      numero = Publicacao.get_attribute_value(protocolo, "numero") or raise ParseError, "Número do Protocolo é obrigatório. (Processo: #{@processo} // Despacho: #{codigo_despacho}"
      data = Publicacao.get_attribute_value(protocolo, "data") or raise ParseError, "Data do Protocolo é obrigatória. (Processo: #{@processo} // Despacho: #{codigo_despacho}"

      Protocolo.new(
        numero: numero,
        data: Publicacao.parse_date(data),
        codigo_servico: Publicacao.get_attribute_value(protocolo, "codigoServico"),
        procurador: Publicacao.get_element_value(protocolo.at_xpath("procurador")),
        requerente: Titular.parse(protocolo.at_xpath("requerente")),
        cedente: Titular.parse(protocolo.at_xpath("cedente")),
        cessionario: Titular.parse(protocolo.at_xpath("cessionario"))
        )
    end
  end
end
