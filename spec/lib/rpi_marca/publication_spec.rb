require 'rpi_marca/publication'
require 'rpi_marca/exceptions'
require 'nokogiri'

describe RpiMarca::Publication do
  # rubocop:disable Metrics/LineLength
  PUBLICACAO_PROTOCOLO_COMPLETO = <<-XML
    <processo numero="829142282">
      <despachos>
        <despacho codigo="IPAS270" nome="Deferimento de petição">
          <texto-complementar>Protocolo: 810110405339 (17/03/2011) Petição (tipo): Anotação de transferência de titularidade decorrente de cisão (349.2) Procurador: CUSTODIO DE ALMEIDA CIA Cedente: I-PARK SOLUÇÕES TECNOLÓGICAS S.A. [BR] Cessionário: I-PARK SOLUÇÕES TECNOLÓGICAS S.A. Detalhes do despacho: ok!</texto-complementar>
          <protocolo numero="810110405339" data="12/11/2009" codigoServico="3371">
            <requerente nome-razao-social="G.A.R. GESTÃO E ADMINISTRAÇÃO E RODOVIAS LTDA" pais="BR" uf="SP"/>
            <cedente nome-razao-social="K.V.M. COMÉRCIO E CONFECÇÕES LTDA-EPP" pais="BR" uf="SP"/>
            <cessionario nome-razao-social="K.V.M. COMÉRCIO E CONFECÇÕES LTDA-EPP"/>
            <procurador>PICOSSE E CALABRESE ADVOGADOS ASSOCIADOS</procurador>
        </protocolo>
        </despacho>
      </despachos>
    </processo>
  XML

  PUBLICACAO_DOIS_DESPACHOS = <<-XML
    <processo numero="829142282">
      <despachos>
        <despacho codigo="IPAS270" nome="Deferimento de petição">
          <texto-complementar>Protocolo: 810110405339 (17/03/2011) Petição (tipo): Anotação de transferência de titularidade decorrente de cisão (349.2) Procurador: CUSTODIO DE ALMEIDA CIA Cedente: I-PARK SOLUÇÕES TECNOLÓGICAS S.A. [BR] Cessionário: I-PARK SOLUÇÕES TECNOLÓGICAS S.A. Detalhes do despacho: ok!</texto-complementar>
          <protocolo numero="810110405339" data="01/07/2013"/>
        </despacho>
        <despacho codigo="IPAS009" nome="Publicação de pedido de registro para oposição">
          <texto-complementar/>
          <protocolo numero="1010101010101010" data="01/12/2012"/>
        </despacho>
      </despachos>
    </processo>
  XML

  PUBLICACAO_SEM_PROTOCOLO = <<-XML
    <processo numero="828247935">
      <despachos>
        <despacho codigo="IPAS142" nome="Sobrestamento do exame de mérito">
          <texto-complementar>Sobrestadores: Processo: 823129900 (MÓDULO E-SECURITY)</texto-complementar>
        </despacho>
      </despachos>
    </processo>
  XML

  TEXTO_COMPLEMENTAR_COM_PROTOCOLO = <<-XML
    <processo numero="905653858">
      <despachos>
        <despacho codigo="IPAS423" nome="Notificação de oposição para manifestação">
          <texto-complementar>850130127025 de 02/07/2013, 850130131596 de 08/07/2013 e 850130122879 de 28/06/2013</texto-complementar>
        </despacho>
      </despachos>
    </processo>
  XML

  PROCURADOR_SEM_PROTOCOLO = <<-XML
    <processo numero="828247935">
      <despachos>
        <despacho codigo="IPAS142" nome="Sobrestamento do exame de mérito">
          <texto-complementar>Sobrestadores: Processo: 823129900 (MÓDULO E-SECURITY)</texto-complementar>
        </despacho>
      </despachos>
      <titulares>
        <titular nome-razao-social="DIGITAL 21 PRODUÇÕES ARTISTICAS LTDA" pais="BR" uf="SP"/>
        <titular nome-razao-social="BROOKFIELD RIO DE JANEIRO EMPREENDIMENTOS IMOBILIÁRIOS S/A." pais="BR" uf="RJ"/>
      </titulares>
      <procurador>LAURA GARKISCH MOREIRA</procurador>
      <sobrestadores>
        <sobrestador marca="MÓDULO E-SECURITY" processo="823129900"/>
      </sobrestadores>
    </processo>
  XML

  DEPOSITO = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <titulares>
        <titular nome-razao-social="OP SPORTS COMERCIAL LTDA EPP" pais="BR" uf="SP"/>
      </titulares>
      <marca apresentacao="Mista" natureza="De Serviço">
        <nome>MC FARLANE TOYS</nome>
      </marca>
      <classes-vienna edicao="4">
        <classe-vienna codigo="27.5.1"/>
        <classe-vienna codigo="27.7.1"/>
      </classes-vienna>
      <classe-nice codigo="35" edicao="10">
        <especificacao>COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;</especificacao>
      </classe-nice>
      <prioridade-unionista>
        <prioridade data="15/02/2012" numero="CTM 010645091" pais="IT"/>
      </prioridade-unionista>
      <apostila>SEM DIREITO AO USO EXCLUSIVO DA EXPRESSÃO &quot;TOYS&quot;.</apostila>
      <procurador>ABM ASSESSORIA  BRASILEIRA DE MARCAS LTDA.</procurador>
    </processo>
  XML

  DEPOSITO_MARCA_FIGURATIVA = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <titulares>
        <titular nome-razao-social="OP SPORTS COMERCIAL LTDA EPP" pais="BR" uf="SP"/>
      </titulares>
      <marca apresentacao="Figurativa" natureza="De Serviço"/>
      <classes-vienna edicao="4">
        <classe-vienna codigo="27.5.1"/>
        <classe-vienna codigo="27.7.1"/>
      </classes-vienna>
      <classe-nice codigo="35" edicao="10">
        <especificacao>COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;</especificacao>
      </classe-nice>
      <prioridade-unionista>
        <prioridade data="15/02/2012" numero="CTM 010645091" pais="IT"/>
      </prioridade-unionista>
      <apostila>SEM DIREITO AO USO EXCLUSIVO DA EXPRESSÃO &quot;TOYS&quot;.</apostila>
      <procurador>ABM ASSESSORIA  BRASILEIRA DE MARCAS LTDA.</procurador>
    </processo>
  XML

  DEPOSITO_MARCA_CERTIFIC = <<-XML
    <processo numero="908163495" data-deposito="22/08/2014">
      <despachos>
        <despacho codigo="IPAS009" nome="Publicação de pedido de registro para oposição (exame formal concluído)"/>
      </despachos>
      <titulares>
        <titular nome-razao-social="INSTITUTO INTERNET NO ESTADO DA ARTE - I-START" pais="BR" uf="SP"/>
      </titulares>
      <marca apresentacao="Mista" natureza="Certific.">
        <nome>istart escola digital segura</nome>
      </marca>
      <classes-vienna edicao="4">
        <classe-vienna codigo="26.4.9"/>
        <classe-vienna codigo="27.5.1"/>
      </classes-vienna>
      <classe-nice codigo="42">
        <especificacao>Certificação de A fim de promover sua missão junto às instituições de ensino, o i. Start desenvolveu o selo escola digital segura, uma ação pioneira de responsabilidade social digital. O selo escola digital segura auxilia a direção a incorporar as tecnologias da informação e comunicação ao ambiente escolar e implantar o uso seguro dos recursos de tecnologia educacional identificando e mitigando possíveis incidentes digitais. Assim o i. Start promove o reconhecimento das instituições de ensino que investem em infraestrutura, formulam e aplicam regulamentos e procedimentos para gestão da informação e dos recursos de tecnologia da informação e comunicação e ainda formam alunos e educadores para segurança da informação e ética digital. Diante desse cenário, o selo escola digital segura reconhece o valor das instituições de ensino que se comprometem com a orientação sobre ética e segurança digital, com indicadores distribuídos em quatro níveis: infraestrutura tecnológica, elaboração de regras e procedimentos quanto ao uso da tecnologia, capacitação de colaboradores e docentes e conscientização do corpo discente e de toda a comunidade relacionada. A conquista do certificado é simbolizada, em cada um dos níveis avaliados, pelo ¿selo escola digital segura¿, que permite à instituição de ensino dar publicidade aos esforços envidados no processo educacional para garantir o uso ético, seguro e legal da tecnologia.; </especificacao>
      </classe-nice>
      <procurador>Diego Perez Martin de Almeida</procurador>
    </processo>
  XML

  DEPOSITO_NCL_SEM_EDICAO = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <classe-nice codigo="35">
        <especificacao>COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;</especificacao>
      </classe-nice>
    </processo>
  XML

  PUBLICACAO_COM_CLASSE_NACIONAL = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <classe-nacional codigo="25">
        <especificacao>Teste</especificacao>
        <sub-classes-nacional>
          <sub-classe-nacional codigo="10"/>
          <sub-classe-nacional codigo="20"/>
        </sub-classes-nacional>
      </classe-nacional>
    </processo>
  XML

  CLASSE_NACIONAL_MAIS_DE_3_SUBCLASSES = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <classe-nacional codigo="25">
        <especificacao>Teste</especificacao>
        <sub-classes-nacional>
          <sub-classe-nacional codigo="10"/>
          <sub-classe-nacional codigo="20"/>
          <sub-classe-nacional codigo="30"/>
          <sub-classe-nacional codigo="40"/>
        </sub-classes-nacional>
      </classe-nacional>
    </processo>
  XML

  CLASSE_LOGOTIPO_MAIS_DE_5_SUBCLASSES = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <classes-vienna edicao="4">
        <classe-vienna codigo="27.5.1"/>
        <classe-vienna codigo="27.7.1"/>
        <classe-vienna codigo="27.9.1"/>
        <classe-vienna codigo="27.11.1"/>
        <classe-vienna codigo="27.13.1"/>
        <classe-vienna codigo="27.15.1"/>
      </classes-vienna>
    </processo>
  XML

  PRIORIDADE_UNIONISTA_SEM_DATA = <<-XML
    <processo data-deposito="25/08/2008" numero="829825584">
      <despachos>
        <despacho codigo="IPAS421" nome="Republicação de pedido para oposição">
          <texto-complementar>por alteração na especificação</texto-complementar>
        </despacho>
      </despachos>
      <prioridade-unionista>
        <prioridade numero="CTM 010645091" pais="IT"/>
      </prioridade-unionista>
    </processo>
  XML

  CONCESSAO_REGISTRO = <<-XML
    <processo data-concessao="10/05/2013" data-deposito="12/04/2010" data-vigencia="10/05/2023" numero="902488309">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro">
          <texto-complementar/>
        </despacho>
      </despachos>
    </processo>
  XML

  CONCESSAO_REGISTRO_SEM_DATA_CONCESSAO = <<-XML
    <processo data-deposito="12/04/2010" data-vigencia="10/05/2023" numero="902488309">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro">
          <texto-complementar/>
        </despacho>
      </despachos>
    </processo>
  XML

  CONCESSAO_REGISTRO_SEM_DATA_VIGENCIA = <<-XML
    <processo data-concessao="10/05/2013" data-deposito="12/04/2010" numero="902488309">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro">
          <texto-complementar/>
        </despacho>
      </despachos>
    </processo>
  XML

  PUBLICACAO_ELEMENTO_NOVO_INVALIDO = <<-XML
    <processo numero="829142282">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro"/>
      </despachos>
      <foo/>
    </processo>
  XML
  # rubocop:enable Metrics/LineLength

  it 'aceita uma string contendo a publicação' do
    publication = DEPOSITO

    expect { RpiMarca::Publication.new(publication) }.not_to raise_error
  end

  it 'aceita um objeto `Nokogiri::XML::Element` contendo a publicação' do
    publication = Nokogiri::XML(DEPOSITO).at_xpath('//processo')

    expect { RpiMarca::Publication.new(publication) }.not_to raise_error
  end

  it 'erro ao instanciar com informações de publicação inválidas' do
    class Foo; end

    expect { RpiMarca::Publication.new(Foo.new) }
      .to raise_error RpiMarca::ParseError
  end

  it 'erro quando um elemento novo/inválido for publicado' do
    expect { RpiMarca::Publication.new(PUBLICACAO_ELEMENTO_NOVO_INVALIDO) }
      .to raise_error RpiMarca::ParseError
  end

  context 'processo' do
    it 'número é identificado corretamente' do
      publication = RpiMarca::Publication.new(PUBLICACAO_PROTOCOLO_COMPLETO)

      expect(publication.application).to eq '829142282'
    end

    it 'erro quando número não é identificado' do
      expect { RpiMarca::Publication.new('<processo numero=""></processo>') }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'pode ter data de deposito' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.filed_on).to eq Date.new(2008, 8, 25)
    end

    it 'pode ter data de concessão e vigência' do
      publication = RpiMarca::Publication.new(CONCESSAO_REGISTRO)

      expect(publication.granted_on).to eq Date.new(2013, 5, 10)
      expect(publication.expires_on).to eq Date.new(2023, 5, 10)
    end

    it 'se tiver data de concessão deve ter data de vigência' do
      expect { RpiMarca::Publication.new(CONCESSAO_REGISTRO_SEM_DATA_VIGENCIA) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'se tiver data de vigência deve ter data de concessao' do
      publication = CONCESSAO_REGISTRO_SEM_DATA_CONCESSAO
      expect { RpiMarca::Publication.new(publication) }
        .to raise_error(RpiMarca::ParseError)
    end
  end

  context 'lista de despachos' do
    it 'erro quando nenhum é publicado' do
      publication = <<-XML
        <processo numero="829142282">
          <despachos/>
        </processo>
      XML

      expect { RpiMarca::Publication.new(publication) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'publicação com um despacho identificado corretamente' do
      publication = RpiMarca::Publication.new(PUBLICACAO_PROTOCOLO_COMPLETO)

      expect(publication.rules.length).to eq 1
    end

    it 'publicação com 2 despachos identificados corretamente' do
      publication = RpiMarca::Publication.new(PUBLICACAO_DOIS_DESPACHOS)

      expect(publication.rules.length).to eq 2
    end
  end

  context 'despacho' do
    it 'erro quando não possuir código IPAS' do
      publication = <<-XML
        <processo numero="829142282">
          <despachos>
            <despacho codigo=""/>
          </despachos>
        </processo>
      XML

      expect { RpiMarca::Publication.new(publication) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'erro quando não possuir descrição do código IPAS' do
      publication = <<-XML
        <processo numero="829142282">
          <despachos>
            <despacho codigo="IPAS009"/>
          </despachos>
        </processo>
      XML

      expect { RpiMarca::Publication.new(publication) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'primeiro despacho tem dados corretos' do
      publication = RpiMarca::Publication.new(PUBLICACAO_DOIS_DESPACHOS)
      rule = publication.rules.first

      expect(rule.ipas).to eq 'IPAS270'
      expect(rule.receipt.number).to eq '810110405339'
      expect(rule.receipt.date).to eq Date.new(2013, 7, 1)
      expect(rule.complement)
        .to eq 'Protocolo: 810110405339 (17/03/2011) Petição (tipo): Anotação' \
          ' de transferência de titularidade decorrente de cisão (349.2) ' \
          'Procurador: CUSTODIO DE ALMEIDA CIA Cedente: I-PARK SOLUÇÕES ' \
          'TECNOLÓGICAS S.A. [BR] Cessionário: I-PARK SOLUÇÕES TECNOLÓGICAS ' \
          'S.A. Detalhes do despacho: ok!'
    end

    it 'segundo despacho tem dados corretos' do
      publication = RpiMarca::Publication.new(PUBLICACAO_DOIS_DESPACHOS)
      rule = publication.rules[1] # segundo

      expect(rule.ipas).to eq 'IPAS009'
      expect(rule.receipt.number).to eq '1010101010101010'
      expect(rule.receipt.date).to eq Date.new(2012, 12, 1)
      expect(rule.complement).to be_nil
    end
  end

  context 'protocolo' do
    it 'deve ter protocolo para despachos onde é obrigatório' do
      # rubocop:disable Metrics/LineLength
      xml = <<-XML
        <processo numero="905653858">
          <despachos>
            <despacho codigo="IPAS270" nome="Notificação de oposição para manifestação">
              <texto-complementar>850130127025 de 02/07/2013, 850130131596 de 08/07/2013 e 850130122879 de 28/06/2013</texto-complementar>
            </despacho>
          </despachos>
        </processo>
      XML
      # rubocop:enable Metrics/LineLength

      expect { RpiMarca::Publication.new(xml) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'não tem protocolo para despachos onde não é obrigatório' do
      expect { RpiMarca::Publication.new(PUBLICACAO_SEM_PROTOCOLO) }
        .not_to raise_error
    end

    it 'protocolo tem dados corretos' do
      publication = RpiMarca::Publication.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      rule = publication.rules.first
      receipt = rule.receipt

      expect(receipt.number).to eq '810110405339'
      expect(receipt.date).to eq Date.new(2009, 11, 12)
      expect(receipt.service_code).to eq '337.1'

    end

    it 'pode ter texto complementar' do
      # rubocop:disable Metrics/LineLength
      xml = <<-XML
        <processo numero="905653858">
          <despachos>
            <despacho codigo="IPAS423" nome="Notificação de oposição para manifestação">
              <texto-complementar>850130127025 de 02/07/2013, 850130131596 de 08/07/2013 e 850130122879 de 28/06/2013</texto-complementar>
            </despacho>
          </despachos>
        </processo>
      XML
      # rubocop:enable Metrics/LineLength

      publication = RpiMarca::Publication.new(xml)
      rule = publication.rules.first

      expect(rule.complement).to eq '850130127025 de 02/07/2013, ' \
        '850130131596 de 08/07/2013 e 850130122879 de 28/06/2013'
    end

    it 'texto complementar pode conter outros protocolos' do
      publication = RpiMarca::Publication.new(TEXTO_COMPLEMENTAR_COM_PROTOCOLO)
      rule = publication.rules.last

      expect(rule.complementary_receipts.length).to eq 3

      receipt1 = rule.complementary_receipts.first
      expect(receipt1.number).to eq '850130127025'
      expect(receipt1.date).to eq Date.new(2013, 7, 2)

      receipt3 = rule.complementary_receipts.last
      expect(receipt3.number).to eq '850130122879'
      expect(receipt3.date).to eq Date.new(2013, 6, 28)
    end

    it 'pode ter procurador' do
      publication = RpiMarca::Publication.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      rule = publication.rules.first
      receipt = rule.receipt

      expect(receipt.agent)
        .to eq 'PICOSSE E CALABRESE ADVOGADOS ASSOCIADOS'
    end

    it 'pode ter requerente' do
      publication = RpiMarca::Publication.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      rule = publication.rules.first
      receipt = rule.receipt
      applicant = receipt.applicant

      expect(applicant.name)
        .to eq 'G.A.R. GESTÃO E ADMINISTRAÇÃO E RODOVIAS LTDA'
      expect(applicant.country).to eq 'BR'
      expect(applicant.state).to eq 'SP'
    end

    it 'pode ter cedente e cessionário' do
      publication = RpiMarca::Publication.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      rule = publication.rules.first
      receipt = rule.receipt
      assignor = receipt.assignor
      assignee = receipt.assignee

      expect(assignor).not_to be_nil
      expect(assignor.name)
        .to eq 'K.V.M. COMÉRCIO E CONFECÇÕES LTDA-EPP'
      expect(assignor.country).to eq 'BR'
      expect(assignor.state).to eq 'SP'

      expect(assignee).not_to be_nil
      expect(assignee.name)
        .to eq 'K.V.M. COMÉRCIO E CONFECÇÕES LTDA-EPP'
      expect(assignee.country).to be_nil
      expect(assignee.state).to be_nil
    end
  end

  context 'classificação NCL, nacional e de logotipo' do
    it 'pode ter classificação NCL' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.ncl).not_to be_nil
      expect(publication.ncl.number).to eq '35'
      expect(publication.ncl.edition).to eq 10
      expect(publication.ncl.goods_services)
        .to eq 'COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, ' \
          'ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A ' \
          'PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;'
    end

    it 'classificação NCL pode vir sem edição' do
      publication = RpiMarca::Publication.new(DEPOSITO_NCL_SEM_EDICAO)

      expect(publication.ncl).not_to be_nil
      expect(publication.ncl.number).to eq '35'
      expect(publication.ncl.edition).to be_nil
      expect(publication.ncl.goods_services)
        .to eq 'COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, ' \
          'ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A ' \
          'PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;'
    end

    it 'pode ter classificação nacional' do
      publication = RpiMarca::Publication.new(PUBLICACAO_COM_CLASSE_NACIONAL)

      expect(publication.national_class).not_to be_nil
      expect(publication.national_class.number).to eq 25
      expect(publication.national_class.subclass1).to eq 10
      expect(publication.national_class.subclass2).to eq 20
      expect(publication.national_class.subclass3).to eq nil
      expect(publication.national_class.goods_services).to eq 'Teste'
    end

    it 'retorna a classificação nacional formatada' do
      publication = RpiMarca::Publication.new(PUBLICACAO_COM_CLASSE_NACIONAL)
      expect(publication.national_class.to_s).to eq '25/10.20'
    end

    it 'classificação nacional não pode ter mais de 3 subclasses' do
      expect { RpiMarca::Publication.new(CLASSE_NACIONAL_MAIS_DE_3_SUBCLASSES) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'pode ter classificação de logotipo' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.vienna_class).not_to be_nil
      expect(publication.vienna_class.edition).to eq 4
      expect(publication.vienna_class.subclass1).to eq '27.5.1'
      expect(publication.vienna_class.subclass2).to eq '27.7.1'
      expect(publication.vienna_class.subclass3).to be_nil
      expect(publication.vienna_class.subclass4).to be_nil
      expect(publication.vienna_class.subclass5).to be_nil
    end

    it 'retorna a classificação de logotipo formatada' do
      publication = RpiMarca::Publication.new(DEPOSITO)
      expect(publication.vienna_class.to_s).to eq '27.5.1 / 27.7.1'
    end

    it 'classificação de logotipo não pode ter mais de 5 classes' do
      expect { RpiMarca::Publication.new(CLASSE_LOGOTIPO_MAIS_DE_5_SUBCLASSES) }
        .to raise_error(RpiMarca::ParseError)
    end
  end

  context 'publicação' do
    it 'pode ter titulares' do
      publication = RpiMarca::Publication.new(PROCURADOR_SEM_PROTOCOLO)
      expect(publication.owners).not_to be_empty
    end

    it 'primeiro titular tem dados corretos' do
      publication = RpiMarca::Publication.new(PROCURADOR_SEM_PROTOCOLO)

      owner = publication.owners.first
      expect(owner.name)
        .to eq 'DIGITAL 21 PRODUÇÕES ARTISTICAS LTDA'
      expect(owner.country).to eq 'BR'
      expect(owner.state).to eq 'SP'
    end

    it 'segundo titular tem dados corretos' do
      publication = RpiMarca::Publication.new(PROCURADOR_SEM_PROTOCOLO)

      owner = publication.owners.last
      expect(owner.name)
        .to eq 'BROOKFIELD RIO DE JANEIRO EMPREENDIMENTOS IMOBILIÁRIOS S/A.'
      expect(owner.country).to eq 'BR'
      expect(owner.state).to eq 'RJ'
    end

    it 'pode ter marca' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.trademark).to eq 'MC FARLANE TOYS'
    end

    it 'não tem marca quando for Figurativa ou Tridimensional' do
      publication = RpiMarca::Publication.new(DEPOSITO_MARCA_FIGURATIVA)

      expect(publication.trademark).to be_nil
    end

    it 'pode ter apresentação' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.kind).to eq 'Mista'
    end

    it 'pode ter natureza' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.nature).to eq 'De Serviço'
    end

    it "natureza 'Certificação' é normalizada" do
      publication = RpiMarca::Publication.new(DEPOSITO_MARCA_CERTIFIC)

      expect(publication.nature).to eq 'Certificação'
    end

    it 'pode ter procurador' do
      publication = RpiMarca::Publication.new(PROCURADOR_SEM_PROTOCOLO)
      expect(publication.agent).to eq 'LAURA GARKISCH MOREIRA'
    end

    it 'pode ter apostila' do
      publication = RpiMarca::Publication.new(DEPOSITO)

      expect(publication.disclaimer)
        .to eq 'SEM DIREITO AO USO EXCLUSIVO DA EXPRESSÃO "TOYS".'
    end

    it 'pode ter prioridade unionista' do
      publication = RpiMarca::Publication.new(DEPOSITO)
      priority = publication.priorities.first

      expect(priority).not_to be_nil
      expect(priority.number).to eq 'CTM 010645091'
      expect(priority.date).to eq Date.new(2012, 2, 15)
      expect(priority.country).to eq 'IT'
    end

    it 'prioridade unionista deve ter data da prioridade' do
      expect { RpiMarca::Publication.new(PRIORIDADE_UNIONISTA_SEM_DATA) }
        .to raise_error(RpiMarca::ParseError)
    end

    it 'pode ter processos sobrestadores' do
      publication = RpiMarca::Publication.new(PROCURADOR_SEM_PROTOCOLO)

      previous_applications = publication.previous_applications
      expect(previous_applications).not_to be_nil

      previous_application = previous_applications.first
      expect(previous_application.application).to eq '823129900'
      expect(previous_application.trademark).to eq 'MÓDULO E-SECURITY'
    end
  end
end
