require 'rpi_marca/helpers'
require 'rpi_marca/owner'
require 'rpi_marca/receipt'
require 'rpi_marca/rule'
require 'rpi_marca/ncl'
require 'rpi_marca/national_class'
require 'rpi_marca/vienna_class'
require 'rpi_marca/priority'
require 'rpi_marca/previous_application'
require 'nokogiri'

module RpiMarca
  class Publication
    attr_reader :application
    attr_reader :rules
    attr_reader :filed_on
    attr_reader :granted_on
    attr_reader :expires_on
    attr_reader :ncl
    attr_reader :national_class
    attr_reader :vienna_class
    attr_reader :owners
    attr_reader :trademark
    attr_reader :kind
    attr_reader :nature
    attr_reader :agent
    attr_reader :disclaimer
    attr_reader :previous_applications
    attr_reader :priorities

    NATURE_NORMALIZATION = {
      'Certific.' => 'Certificação'
    }

    def initialize(publication)
      @rules = []
      @owners = []
      @previous_applications = []
      @priorities = []

      element = validate_and_parse_publication(publication)
      parse_element_children(element)
    end

    protected

    def validate_and_parse_publication(element)
      element =
        if element.is_a? Nokogiri::XML::Element
          element
        elsif element.is_a? String
          Nokogiri::XML(element).at_xpath('//processo')
        else
          fail ParseError, "Input couldn't be recognized as a publication"
        end

      fail ParseError if element.name != 'processo'

      element
    end

    def parse_element_children(publication)
      parse_element_processo(publication)

      publication.elements.each do |el|
        normalized_element_name = el.name.gsub('-', '_')
        parse_method = "parse_element_#{normalized_element_name}".to_sym

        fail ParseError unless respond_to?(parse_method, true)

        __send__(parse_method, el)
      end
    end

    def parse_element_processo(el)
      @application =
        Helpers.get_attribute_value(el, 'numero') or fail ParseError
      @filed_on =
        Helpers.parse_date(Helpers.get_attribute_value(el, 'data-deposito'))
      @granted_on =
        Helpers.parse_date(Helpers.get_attribute_value(el, 'data-concessao'))
      @expires_on =
        Helpers.parse_date(Helpers.get_attribute_value(el, 'data-vigencia'))

      fail ParseError if @granted_on && @expires_on.nil?
      fail ParseError if @expires_on && @granted_on.nil?
    end

    def parse_element_despachos(el)
      el = el.elements
      fail ParseError if el.empty?

      @rules = el.map { |rule| Rule.parse(rule) }
    end

    def parse_element_procurador(el)
      @agent = Helpers.get_element_value(el)
    end

    def parse_element_titulares(el)
      @owners = el.elements.map { |owner| Owner.parse(owner) }
    end

    def parse_element_sobrestadores(el)
      @previous_applications =
        el.elements.map { |application| PreviousApplication.parse(application) }
    end

    def parse_element_marca(el)
      @trademark = Helpers.get_element_value(el.at_xpath('.//nome'))
      @kind = Helpers.get_attribute_value(el, 'apresentacao')
      nature = Helpers.get_attribute_value(el, 'natureza')
      @nature = NATURE_NORMALIZATION.fetch(nature, nature)
    end

    def parse_element_classe_nice(el)
      @ncl = Ncl.parse(el)
    end

    def parse_element_classe_nacional(el)
      @national_class = NationalClass.parse(el)
    end

    def parse_element_classes_vienna(el)
      @vienna_class = ViennaClass.parse(el)
    end

    def parse_element_prioridade_unionista(el)
      @priorities = el.elements.map { |prio| Priority.parse(prio) }
    end

    def parse_element_apostila(el)
      @disclaimer = Helpers.get_element_value(el)
    end
  end
end
