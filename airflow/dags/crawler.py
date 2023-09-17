import yaml
import httpx
import os
import xmltodict
import json
import pandas as pd
from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta
import sqlalchemy as sa
from sqlalchemy.engine.base import Engine


def criaEngine() -> Engine:
    uri = f"postgresql+psycopg2://{os.getenv('DB_TCC_USER')}:{os.getenv('DB_TCC_PASS')}@{os.getenv('DB_TCC_HOST')}:{str(os.getenv('DB_TCC_PORT'))}/{os.getenv('DB_TCC_DBNAME')}"
    engine = sa.create_engine(
        uri,
        connect_args={
            'options': '-csearch_path={}'.format(os.getenv('DB_TCC_SCHEMA'))}
    )
    return engine


class Report:

    def __init__(self, anoReferencia: int, mesReferencia: int, path: str) -> None:
        self.__mesReferencia: int = mesReferencia
        self.__anoReferencia: int = anoReferencia
        self.__method = "GET"
        self.__controller: str = os.getenv("TCC_CONTROLLER")
        self.__path: str = path
        self.__client = httpx.Client()
        self.__data = None

    def _get_url(self) -> str:
        return "https://" + self.__controller + self.__path + f"?ano={self.__anoReferencia}&mes={self.__mesReferencia}"

    def run(self) -> None:
        self._requisitaApi()
        self.insereDados()

    def _requisitaApi(self) -> None:
        """
        Função que requisita a API e armazena os dados de resposta em self.__data.
        """
        url: str = self._get_url()
        print(
            f"{datetime.now().strftime('%Y-%m-%d %H:%M')} - Requisitando a URL: {url}")
        headersList = {}
        dados = self.__client.get(url, headers=headersList)
        if dados.status_code != 200:
            raise Exception(
                "Erro ao requisitar a URL: {url}. Status Code: {dados.status_code}. Erro: {dados.text}")
        self.__data: httpx.Response = dados

    def insereDados(self) -> None:
        """
        Funcao que insere os dados obtidos pela API no banco de dados.
        """
        df: pd.DataFrame = self.parseJson()
        engine: Engine = criaEngine()
        self._apagaDadosDb(engine, str(self.__path).replace('/', ''))
        print(
            f"{datetime.now().strftime('%Y-%m-%d %H:%M')} - Inserindo dados no banco de dados.")
        df['data_criacao_registro'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        df.to_sql(f"{str(self.__path).replace('/','')}",
                  con=engine, if_exists='append', index=False)
        print(
            f"{datetime.now().strftime('%Y-%m-%d %H:%M')} - Dados inseridos com sucesso!")
        engine.dispose()

    def parseJson(self) -> pd.DataFrame:
        """
        Função que converte o JSON obtido pela API em um DataFrame.
        """
        dadosDict = xmltodict.parse(self.__data.text)
        dadosJson = json.loads(dadosDict['string']['#text'])
        df = pd.DataFrame(dadosJson)
        return df

    def _apagaDadosDb(self, engine: Engine, tabela: str) -> None:
        """
        Função que apaga os dados da tabela do banco de dados de acordo com o mês e ano de referência.
        :param engine: Engine do banco de dados.
        :param tabela: Nome da tabela a ser apagada.
        """
        print(f"{datetime.now().strftime('%Y-%m-%d %H:%M')} - Apagando dados da tabela {tabela} no mes {self.__mesReferencia}/{self.__anoReferencia}")
        _sql = f"""
            DELETE FROM {tabela}
            WHERE CAST(ano AS INTEGER) = {self.__anoReferencia}
            AND CAST(SPLIT_PART(mes, ' - ', 1) AS INTEGER) = {self.__mesReferencia}
        """
        print(_sql)
        engine.execute(_sql)
        print(
            f"{datetime.now().strftime('%Y-%m-%d %H:%M')} - Dados apagados com sucesso!")


def main():

    from time import sleep

    _PATHS = [
        "/json_empenhos",
        "/json_liquidacoes",
        "/json_pagamentos",
        "/json_diarias",
        "/json_obras",
    ]

    periodoReferencia = (
        datetime.now() - relativedelta(months=int(os.getenv("TCC_PERIODO"))))
    print(f"Período de referência: {periodoReferencia.strftime('%m/%Y')}")
    mesReferencia = periodoReferencia.month
    anoReferencia = periodoReferencia.year

    for rota in _PATHS:
        print(f"Requisitando a Rota: '{rota}'")
        report = Report(
            anoReferencia=anoReferencia,
            mesReferencia=mesReferencia,
            path=rota
        )
        report.run()
        print(
            f"Rota '{rota}' requisitada com sucesso! Aguardando 60 segundos para a próxima requisição...'")
        sleep(60)
