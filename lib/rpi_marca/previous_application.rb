module RpiMarca
  class PreviousApplication
    attr_reader :application, :trademark

    def initialize(application:, trademark:)
      @application = application
      @trademark = trademark
    end

    def self.parse(el)
      return unless el

      new(
        application: Helpers.get_attribute_value(el, 'processo'),
        trademark: Helpers.get_attribute_value(el, 'marca')
      )
    end
  end
end
