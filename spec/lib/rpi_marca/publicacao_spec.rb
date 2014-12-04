require "rpi_marca/publicacao"
require "rpi_marca/exceptions"
require "nokogiri"

describe RpiMarca::Publicacao do
  # rubocop:disable Metrics/LineLength
  PUBLICACAO_PROTOCOLO_COMPLETO = <<-PUBLICACAO
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
  PUBLICACAO

  PUBLICACAO_DOIS_DESPACHOS = <<-PUBLICACAO
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
  PUBLICACAO

  PUBLICACAO_SEM_PROTOCOLO = <<-PUBLICACAO
    <processo numero="828247935">
      <despachos>
        <despacho codigo="IPAS142" nome="Sobrestamento do exame de mérito">
          <texto-complementar>Sobrestadores: Processo: 823129900 (MÓDULO E-SECURITY)</texto-complementar>
        </despacho>
      </despachos>
    </processo>
  PUBLICACAO

  TEXTO_COMPLEMENTAR_COM_PROTOCOLO = <<-PUBLICACAO
    <processo numero="905653858">
      <despachos>
        <despacho codigo="IPAS423" nome="Notificação de oposição para manifestação">
          <texto-complementar>850130127025 de 02/07/2013, 850130131596 de 08/07/2013 e 850130122879 de 28/06/2013</texto-complementar>
        </despacho>
      </despachos>
    </processo>
  PUBLICACAO

  PROCURADOR_SEM_PROTOCOLO = <<-PUBLICACAO
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
  PUBLICACAO

  DEPOSITO = <<-PUBLICACAO
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
  PUBLICACAO

  DEPOSITO_MARCA_FIGURATIVA = <<-PUBLICACAO
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
  PUBLICACAO

  DEPOSITO_MARCA_CERTIFIC = <<-PUBLICACAO
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
  PUBLICACAO

  DEPOSITO_NCL_SEM_EDICAO = <<-PUBLICACAO
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
  PUBLICACAO

  PUBLICACAO_COM_CLASSE_NACIONAL = <<-PUBLICACAO
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
  PUBLICACAO

  CLASSE_NACIONAL_MAIS_DE_3_SUBCLASSES = <<-PUBLICACAO
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
  PUBLICACAO

  CLASSE_LOGOTIPO_MAIS_DE_5_SUBCLASSES = <<-PUBLICACAO
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
  PUBLICACAO

  PRIORIDADE_UNIONISTA_SEM_DATA = <<-PUBLICACAO
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
  PUBLICACAO

  CONCESSAO_REGISTRO = <<-PUBLICACAO
    <processo data-concessao="10/05/2013" data-deposito="12/04/2010" data-vigencia="10/05/2023" numero="902488309">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro">
          <texto-complementar/>
        </despacho>
      </despachos>
    </processo>
  PUBLICACAO

  CONCESSAO_REGISTRO_SEM_DATA_CONCESSAO = <<-PUBLICACAO
    <processo data-deposito="12/04/2010" data-vigencia="10/05/2023" numero="902488309">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro">
          <texto-complementar/>
        </despacho>
      </despachos>
    </processo>
  PUBLICACAO

  CONCESSAO_REGISTRO_SEM_DATA_VIGENCIA = <<-PUBLICACAO
    <processo data-concessao="10/05/2013" data-deposito="12/04/2010" numero="902488309">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro">
          <texto-complementar/>
        </despacho>
      </despachos>
    </processo>
  PUBLICACAO

  PUBLICACAO_ELEMENTO_NOVO_INVALIDO = <<-PUBLICACAO
    <processo numero="829142282">
      <despachos>
        <despacho codigo="IPAS158" nome="Concessão de registro"/>
      </despachos>
      <foo/>
    </processo>
  PUBLICACAO
  # rubocop:enable Metrics/LineLength

  it "aceita uma string contendo a publicação" do
    publicacao = DEPOSITO

    expect { RpiMarca::Publicacao.new(publicacao) }.not_to raise_error
  end

  it "aceita um objeto `Nokogiri::XML::Element` contendo a publicação" do
    publicacao = Nokogiri::XML(DEPOSITO).at_xpath("//processo")

    expect { RpiMarca::Publicacao.new(publicacao) }.not_to raise_error
  end

  it "erro ao instanciar com informações de publicação inválidas" do
    class Foo; end

    expect { RpiMarca::Publicacao.new(Foo.new) }
      .to raise_error RpiMarca::ParseError
  end

  it "erro quando um elemento novo/inválido for publicado" do
    expect { RpiMarca::Publicacao.new(PUBLICACAO_ELEMENTO_NOVO_INVALIDO) }
      .to raise_error RpiMarca::ParseError
  end

  context "processo" do
    it "número é identificado corretamente" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_PROTOCOLO_COMPLETO)

      expect(publicacao.processo).to eq "829142282"
    end

    it "erro quando número não é identificado" do
      expect { RpiMarca::Publicacao.new('<processo numero=""></processo>') }
        .to raise_error(RpiMarca::ParseError)
    end

    it "pode ter data de deposito" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.deposito).to eq Date.new(2008, 8, 25)
    end

    it "pode ter data de concessão e vigência" do
      publicacao = RpiMarca::Publicacao.new(CONCESSAO_REGISTRO)

      expect(publicacao.concessao).to eq Date.new(2013, 5, 10)
      expect(publicacao.vigencia).to eq Date.new(2023, 5, 10)
    end

    it "se tiver data de concessão deve ter data de vigência" do
      expect { RpiMarca::Publicacao.new(CONCESSAO_REGISTRO_SEM_DATA_VIGENCIA) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "se tiver data de vigência deve ter data de concessao" do
      expect { RpiMarca::Publicacao.new(CONCESSAO_REGISTRO_SEM_DATA_CONCESSAO) }
        .to raise_error(RpiMarca::ParseError)
    end
  end

  context "lista de despachos" do
    it "erro quando nenhum é publicado" do
      publicacao = <<-PUBLICACAO
        <processo numero="829142282">
          <despachos/>
        </processo>
      PUBLICACAO

      expect { RpiMarca::Publicacao.new(publicacao) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "publicação com um despacho identificado corretamente" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_PROTOCOLO_COMPLETO)

      expect(publicacao.despachos.length).to eq 1
    end

    it "publicação com 2 despachos identificados corretamente" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_DOIS_DESPACHOS)

      expect(publicacao.despachos.length).to eq 2
    end
  end

  context "despacho" do
    it "erro quando não possuir código IPAS" do
      publicacao = <<-PUBLICACAO
        <processo numero="829142282">
          <despachos>
            <despacho codigo=""/>
          </despachos>
        </processo>
      PUBLICACAO

      expect { RpiMarca::Publicacao.new(publicacao) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "erro quando não possuir descrição do código IPAS" do
      publicacao = <<-PUBLICACAO
        <processo numero="829142282">
          <despachos>
            <despacho codigo="IPAS009"/>
          </despachos>
        </processo>
      PUBLICACAO

      expect { RpiMarca::Publicacao.new(publicacao) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "primeiro despacho tem dados corretos" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_DOIS_DESPACHOS)
      despacho = publicacao.despachos.first

      expect(despacho.codigo).to eq "IPAS270"
      expect(despacho.protocolo.numero).to eq "810110405339"
      expect(despacho.protocolo.data).to eq Date.new(2013, 7, 1)
      expect(despacho.complemento)
        .to eq "Protocolo: 810110405339 (17/03/2011) Petição (tipo): Anotação" \
          " de transferência de titularidade decorrente de cisão (349.2) " \
          "Procurador: CUSTODIO DE ALMEIDA CIA Cedente: I-PARK SOLUÇÕES " \
          "TECNOLÓGICAS S.A. [BR] Cessionário: I-PARK SOLUÇÕES TECNOLÓGICAS " \
          "S.A. Detalhes do despacho: ok!"
    end

    it "segundo despacho tem dados corretos" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_DOIS_DESPACHOS)
      despacho = publicacao.despachos[1] # segundo

      expect(despacho.codigo).to eq "IPAS009"
      expect(despacho.protocolo.numero).to eq "1010101010101010"
      expect(despacho.protocolo.data).to eq Date.new(2012, 12, 1)
      expect(despacho.complemento).to be_nil
    end
  end

  context "protocolo" do
    it "deve ter protocolo para despachos onde é obrigatório" do
      # rubocop:disable Metrics/LineLength
      xml = <<-PUBLICACAO
        <processo numero="905653858">
          <despachos>
            <despacho codigo="IPAS270" nome="Notificação de oposição para manifestação">
              <texto-complementar>850130127025 de 02/07/2013, 850130131596 de 08/07/2013 e 850130122879 de 28/06/2013</texto-complementar>
            </despacho>
          </despachos>
        </processo>
      PUBLICACAO
      # rubocop:enable Metrics/LineLength

      expect { RpiMarca::Publicacao.new(xml) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "não tem protocolo para despachos onde não é obrigatório" do
      expect { RpiMarca::Publicacao.new(PUBLICACAO_SEM_PROTOCOLO) }
        .not_to raise_error
    end

    it "protocolo tem dados corretos" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      despacho = publicacao.despachos.first
      protocolo = despacho.protocolo

      expect(protocolo.numero).to eq "810110405339"
      expect(protocolo.data).to eq Date.new(2009, 11, 12)
      expect(protocolo.codigo_servico).to eq "337.1"

    end

    it "pode ter texto complementar" do
      # rubocop:disable Metrics/LineLength
      xml = <<-PUBLICACAO
        <processo numero="905653858">
          <despachos>
            <despacho codigo="IPAS423" nome="Notificação de oposição para manifestação">
              <texto-complementar>850130127025 de 02/07/2013, 850130131596 de 08/07/2013 e 850130122879 de 28/06/2013</texto-complementar>
            </despacho>
          </despachos>
        </processo>
      PUBLICACAO
      # rubocop:enable Metrics/LineLength

      publicacao = RpiMarca::Publicacao.new(xml)
      despacho = publicacao.despachos.first

      expect(despacho.complemento).to eq "850130127025 de 02/07/2013, " \
        "850130131596 de 08/07/2013 e 850130122879 de 28/06/2013"
    end

    it "texto complementar pode conter outros protocolos" do
      publicacao = RpiMarca::Publicacao.new(TEXTO_COMPLEMENTAR_COM_PROTOCOLO)
      despacho = publicacao.despachos.last

      expect(despacho.protocolos_complemento.length).to eq 3

      protocolo1 = despacho.protocolos_complemento.first
      expect(protocolo1.numero).to eq "850130127025"
      expect(protocolo1.data).to eq Date.new(2013, 7, 2)

      protocolo3 = despacho.protocolos_complemento.last
      expect(protocolo3.numero).to eq "850130122879"
      expect(protocolo3.data).to eq Date.new(2013, 6, 28)
    end

    it "pode ter procurador" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      despacho = publicacao.despachos.first
      protocolo = despacho.protocolo

      expect(protocolo.procurador)
        .to eq "PICOSSE E CALABRESE ADVOGADOS ASSOCIADOS"
    end

    it "pode ter requerente" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      despacho = publicacao.despachos.first
      protocolo = despacho.protocolo
      requerente = protocolo.requerente

      expect(requerente.nome_razao_social)
        .to eq "G.A.R. GESTÃO E ADMINISTRAÇÃO E RODOVIAS LTDA"
      expect(requerente.pais).to eq "BR"
      expect(requerente.uf).to eq "SP"
    end

    it "pode ter cedente e cessionário" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_PROTOCOLO_COMPLETO)
      despacho = publicacao.despachos.first
      protocolo = despacho.protocolo
      cedente = protocolo.cedente
      cessionario = protocolo.cessionario

      expect(cedente).not_to be_nil
      expect(cedente.nome_razao_social)
        .to eq "K.V.M. COMÉRCIO E CONFECÇÕES LTDA-EPP"
      expect(cedente.pais).to eq "BR"
      expect(cedente.uf).to eq "SP"

      expect(cessionario).not_to be_nil
      expect(cessionario.nome_razao_social)
        .to eq "K.V.M. COMÉRCIO E CONFECÇÕES LTDA-EPP"
      expect(cessionario.pais).to be_nil
      expect(cessionario.uf).to be_nil
    end
  end

  context "classificação NCL, nacional e de logotipo" do
    it "pode ter classificação NCL" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.ncl).not_to be_nil
      expect(publicacao.ncl.classe).to eq "35"
      expect(publicacao.ncl.edicao).to eq 10
      expect(publicacao.ncl.especificacao)
        .to eq "COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, " \
          "ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A " \
          "PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;"
    end

    it "classificação NCL pode vir sem edição" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO_NCL_SEM_EDICAO)

      expect(publicacao.ncl).not_to be_nil
      expect(publicacao.ncl.classe).to eq "35"
      expect(publicacao.ncl.edicao).to be_nil
      expect(publicacao.ncl.especificacao)
        .to eq "COMÉRCIO VAREJISTA ATRAVÉS DE QUALQUER MEIO DE BONECOS, " \
          "ESTÁTUAS, DIORAMAS, BRINQUEDOS COLECIONÁVEIS, RELACIONADOS A " \
          "PERSONAGENS DE FILMES E SÉRIES DE TV E VIDEOGAMES.;"
    end

    it "pode ter classificação nacional" do
      publicacao = RpiMarca::Publicacao.new(PUBLICACAO_COM_CLASSE_NACIONAL)

      expect(publicacao.classe_nacional).not_to be_nil
      expect(publicacao.classe_nacional.classe).to eq 25
      expect(publicacao.classe_nacional.subclasse1).to eq 10
      expect(publicacao.classe_nacional.subclasse2).to eq 20
      expect(publicacao.classe_nacional.subclasse3).to eq nil
      expect(publicacao.classe_nacional.especificacao).to eq "Teste"
    end

    it "classificação nacional não pode ter mais de 3 subclasses" do
      expect { RpiMarca::Publicacao.new(CLASSE_NACIONAL_MAIS_DE_3_SUBCLASSES) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "pode ter classificação de logotipo" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.classe_vienna).not_to be_nil
      expect(publicacao.classe_vienna.edicao).to eq 4
      expect(publicacao.classe_vienna.classe1).to eq "27.5.1"
      expect(publicacao.classe_vienna.classe2).to eq "27.7.1"
      expect(publicacao.classe_vienna.classe3).to be_nil
      expect(publicacao.classe_vienna.classe4).to be_nil
      expect(publicacao.classe_vienna.classe5).to be_nil
    end

    it "classificação de logotipo não pode ter mais de 5 classes" do
      expect { RpiMarca::Publicacao.new(CLASSE_LOGOTIPO_MAIS_DE_5_SUBCLASSES) }
        .to raise_error(RpiMarca::ParseError)
    end
  end

  context "publicação" do
    it "pode ter titulares" do
      publicacao = RpiMarca::Publicacao.new(PROCURADOR_SEM_PROTOCOLO)
      expect(publicacao.titulares).not_to be_empty
    end

    it "primeiro titular tem dados corretos" do
      publicacao = RpiMarca::Publicacao.new(PROCURADOR_SEM_PROTOCOLO)

      titular = publicacao.titulares.first
      expect(titular.nome_razao_social)
        .to eq "DIGITAL 21 PRODUÇÕES ARTISTICAS LTDA"
      expect(titular.pais).to eq "BR"
      expect(titular.uf).to eq "SP"
    end

    it "segundo titular tem dados corretos" do
      publicacao = RpiMarca::Publicacao.new(PROCURADOR_SEM_PROTOCOLO)

      titular = publicacao.titulares.last
      expect(titular.nome_razao_social)
        .to eq "BROOKFIELD RIO DE JANEIRO EMPREENDIMENTOS IMOBILIÁRIOS S/A."
      expect(titular.pais).to eq "BR"
      expect(titular.uf).to eq "RJ"
    end

    it "pode ter marca" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.marca).to eq 'MC FARLANE TOYS'
    end

    it "não tem marca quando for Figurativa ou Tridimensional" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO_MARCA_FIGURATIVA)

      expect(publicacao.marca).to be_nil
    end

    it "pode ter apresentação" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.apresentacao).to eq "Mista"
    end

    it "pode ter natureza" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.natureza).to eq "De Serviço"
    end

    it "natureza 'Certificação' é normalizada" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO_MARCA_CERTIFIC)

      expect(publicacao.natureza).to eq "Certificação"
    end

    it "pode ter procurador" do
      publicacao = RpiMarca::Publicacao.new(PROCURADOR_SEM_PROTOCOLO)
      expect(publicacao.procurador).to eq "LAURA GARKISCH MOREIRA"
    end

    it "pode ter apostila" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)

      expect(publicacao.apostila)
        .to eq 'SEM DIREITO AO USO EXCLUSIVO DA EXPRESSÃO "TOYS".'
    end

    it "pode ter prioridade unionista" do
      publicacao = RpiMarca::Publicacao.new(DEPOSITO)
      prioridade = publicacao.prioridades.first

      expect(prioridade).not_to be_nil
      expect(prioridade.numero).to eq "CTM 010645091"
      expect(prioridade.data).to eq Date.new(2012, 2, 15)
      expect(prioridade.pais).to eq "IT"
    end

    it "prioridade unionista deve ter data da prioridade" do
      expect { RpiMarca::Publicacao.new(PRIORIDADE_UNIONISTA_SEM_DATA) }
        .to raise_error(RpiMarca::ParseError)
    end

    it "pode ter processos sobrestadores" do
      publicacao = RpiMarca::Publicacao.new(PROCURADOR_SEM_PROTOCOLO)

      sobrestadores = publicacao.sobrestadores
      expect(sobrestadores).not_to be_nil

      sobrestador = sobrestadores.first
      expect(sobrestador.processo).to eq "823129900"
      expect(sobrestador.marca).to eq "MÓDULO E-SECURITY"
    end
  end
end
