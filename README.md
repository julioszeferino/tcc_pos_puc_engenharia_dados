# Criacao de um Processo de ELT utilizando Python, Airflow, DBT e Metabase

> Fluxo de dados que coleta os dados da API de despesas , realize o tratamento de dados, modelagem dimensional e criacao de painel com indicadores de analise. Projeto construido como trabalho de conclusao de curso da Pos Graduacao em Engenharia de Dados.

- O pipeline foi criado a partir dos dados disponibilizados pela API de despesas da prefeitura de Tres Coracoes-MG.
- O projeto extrai os dados da API utilizando a linguagem `Python` e realiza o tratamento e modelagem dos dados utilizando o `DBT`.
- Os dados sao armazenados no banco de dados `Postgres`.
- Toda a execucao do projeto e orquestrada pelo `Apache Airflow`.
- Ao final, a analise dos dados e disponibilizada via `Metabase`.

![Alt text](docs/media/arquitetura.png)

## Stack de Tecnologias
- [Apache Airflow v2.7.1](https://airflow.apache.org/)
- [DBT v1.6.3](https://www.getdbt.com/)
- [Docker v24.0.6](https://docs.docker.com/)
- [Docker Compose v2.21.0]()
- [Metabase v0.47.2](https://www.metabase.com/)
- [PostgreSQL v13.12](https://www.postgresql.org/)
- [Python v3.8.18](https://www.python.org/)

## Decisoes Arquiteturais do Projeto
O `Apache Airflow` e o orquestrador de pipelines mais utilizado do mercado, personalizavel e permite a escalabilidade do projeto com a possibilidade de processamento distribuido.

O `DBT` e uma ferramenta muito poderosa no tratamento de dados, pode ser orquestrada via Apache Airflow e, permite que os usuarios utilizem a linguagem SQL nos scripts das transformacoes.

O banco de dados `Postgres` e um software de codigo aberto e esta entre os melhores da sua categoria. E escalavel, extensivel e possui um desempenho para a maioria dos casos.

O `Docker` permite uma maior compatibilidade e flexibilidade no ambiente de execucao do projeto. Alem disso pode ser implementado nao apenas em servidores como tambem em solucoes serverless disponiveis em todas as plataformas de cloud.

O `Metabase` tem uma interface simples e intuitiva, permitindo que ate mesmo os usuarios de negocio construam relatorios interativos e analise de dados de maneira eficiente e com poucos cliques.

## Pipeline de Dados
![Alt text](docs/media/pipeline.png)
1. **executaCrawler**: task responsavel por requisitar a API e salvar os dados em tabelas do banco de dados no schema de staging.
2. **dbtRun**: task responsavel por ser o gatilho de execucao das transformacoes do DBT. Tem como funcao obter obter os dados da camada de staging, realizar as transformacoes necessarias e salvar os dadosno schema warehouse para serem que sejam consumidos

## Modelo Multidimensional do Data Warehouse
![Alt text](docs/media/modelo.png)
- **fato_despesas**: tabela que contem os registros das despesas agrupadas por competencia, elemento da despesa, favorecido e tipo da despesa.
- **dim_favorecidos**: dimensao que contem os registros de todos aqueles que receberam os valores pagos pela prefeitura.
- **dim_elemento_despesa**: dimensao que contem o registro de todos os destinos das despesas.
- **dim_tempo**: dimensao auxiliar para analises ao longo do tempo.

## Como Executar o Projeto
A execucao do projeto e feita via `docker`, podendo ser executado pelo gerenciador `docker compose` com o seguinte comando:

```bash
$ docker compose up -d
```

## Dashboard
![Alt text](docs/media/dashboard.gif)
O acesso ao dashboard pode ser feito via http://localhost:3000 utilizando as seguintes credenciais de acesso:

**login**: julioszeferino@gmail.com

**senha**: 123.AFVCy

## Referencias
Documentacao da API de Despesas: https://trescoracoes-mg.portaltp.com.br/api/dadosabertos.aspx

Instalacao do Docker Engine: https://docs.docker.com/engine/install/

