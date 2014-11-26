require "rpi_marca/revista"

describe RpiMarca::Revista do
  RPI_2240 = <<-REVISTA
    <?xml version="1.0" encoding="UTF-8" ?>
    <revista numero="2240" data="10/12/2013">
      <processo numero="905687116" data-deposito="18/12/2012">
        <despachos>
          <despacho codigo="IPAS009" nome="Publicação de pedido de registro para oposição"/>
        </despachos>
        <titulares>
          <titular nome-razao-social="CINTIA DEL REY" pais="BR" uf="SP"/>
        </titulares>
        <marca apresentacao="Mista" natureza="De Produto">
          <nome>Cupcakes for fun</nome>
        </marca>
        <classes-vienna edicao="4">
          <classe-vienna codigo="8.1.17"/>
        </classes-vienna>
        <classe-nice codigo="30">
          <especificacao>Confeitos; Bolo, preparado para consumo final, confeitado ou não;</especificacao>
        </classe-nice>
      </processo>
      <processo numero="840233841" data-deposito="15/08/2012">
        <despachos>
          <despacho codigo="IPAS009" nome="Publicação de pedido de registro para oposição">
            <texto-complementar>Imagem da Marca alterada.</texto-complementar>
          </despacho>
        </despachos>
        <titulares>
          <titular nome-razao-social="GRAVIA ESQUALITY INDÚSTRIA METALÚRICA LTDA" pais="BR" uf="GO"/>
        </titulares>
        <marca apresentacao="Mista" natureza="De Serviço">
          <nome>ELITE</nome>
        </marca>
        <classes-vienna edicao="4">
          <classe-vienna codigo="26.4.7"/>
          <classe-vienna codigo="27.5.1"/>
        </classes-vienna>
        <classe-nice codigo="35">
          <especificacao>COMÉRCIO, IMPORTAÇÃO E EXPORTAÇÃO DE PRODUTOS METALÚRGICOS; COMÉRCIO (ATRAVÉS DE QUALQUER MEIO) DE PORTAS E JANELAS DE AÇO, ALUMÍNIO.; </especificacao>
        </classe-nice>
        <procurador>VILAGE MARCAS &amp; PATENTES S/S LTDA</procurador>
      </processo>
      <processo numero="905688198" data-deposito="18/12/2012">
        <despachos>
          <despacho codigo="IPAS009" nome="Publicação de pedido de registro para oposição"/>
        </despachos>
        <titulares>
          <titular nome-razao-social="CDTA - CENTRO DE DESENVOLVIMENTO DE TECNOLOGIAS AMBIENTAIS LTDA" pais="BR" uf="PR"/>
        </titulares>
        <marca apresentacao="Mista" natureza="De Serviço">
          <nome>CDTA - TECNOLOGIA AMBIENTAL</nome>
        </marca>
        <classes-vienna edicao="4">
          <classe-vienna codigo="5.3.14"/>
          <classe-vienna codigo="15.9.18"/>
          <classe-vienna codigo="27.5.1"/>
          <classe-vienna codigo="27.5.8"/>
        </classes-vienna>
        <classe-nice codigo="42">
          <especificacao>Proteção ambiental (Pesquisa no campo de - ) - [Consultoria em]; Proteção ambiental (Pesquisa no campo de - ) - [Assessoria em]; Proteção ambiental (Pesquisa no campo de - ); Assessoria, consultoria e informações sobre engenharia - [Consultoria em]; Assessoria, consultoria e informações sobre engenharia - [Assessoria em]; Projeto de engenharia de qualquer natureza - [Consultoria em]; Projeto de engenharia de qualquer natureza - [Assessoria em]; Projeto de engenharia de qualquer natureza;</especificacao>
        </classe-nice>
        <procurador>HÉLIO ROBERTO LINHARES DE OLIVEIRA</procurador>
      </processo>
    </revista>
  REVISTA

  RPI_INVALIDA = <<-REVISTA
    <?xml version="1.0" encoding="UTF-8" ?>
    <revista numero="2240" data="10/12/2013">
      <processo numero="905687116" data-deposito="18/12/2012">
        <despachos>
          <despacho codigo="IPAS009" nome="Publicação de pedido de registro para oposição"/>
        </despachos>
      </processo>
      <foo/>
    </revista>
  REVISTA

  it "tem numero e data de publicação" do
    revista = RpiMarca::Revista.new(RPI_2240)

    expect(revista.numero).to eq 2240
    expect(revista.data_publicacao).to eq Date.new(2013, 12, 10)
  end

  it "possui várias publicações" do
    revista = RpiMarca::Revista.new(RPI_2240)

    expect(revista.count).to eq 3
  end

  it "retorna objeto contendo dados da publicação" do
    revista = RpiMarca::Revista.new(RPI_2240)
    publicacao = revista.first

    expect(publicacao).to be_a RpiMarca::Publicacao
  end

  it "retorna um Enumerator" do
    revista = RpiMarca::Revista.new(RPI_2240)

    expect(revista.each).to be_a Enumerator
  end

  describe "#valid?" do
    it "XML é válido" do
      revista = RpiMarca::Revista.new(RPI_2240)

      expect(revista).to be_valid
    end

    it "erro quando XML é inválido" do
      revista = RpiMarca::Revista.new(RPI_INVALIDA)

      expect(revista).not_to be_valid
    end
  end
end
