# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rpi_marca/version'

Gem::Specification.new do |spec|
  spec.name          = "rpi_marca"
  spec.version       = RpiMarca::VERSION
  spec.authors       = ["Luiz Damim"]
  spec.email         = ["luizdamim@outlook.com"]
  spec.summary       = %q{Leitura da RPI de Marcas do INPI em formato XML.}
  spec.description   = %q{Faz a leitura da RPI de Marcas do INPI em formato XML, transformando em um objeto Ruby para processamento.}
  spec.homepage      = "https://github.com/automatto/rpi_marca"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "nokogiri", "~> 1.6"
end
