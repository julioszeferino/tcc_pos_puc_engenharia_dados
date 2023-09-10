import yaml
import httpx
import xmltodict
import json
import pandas as pd
from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta
import sqlalchemy as sa

def criaEngine(bd):
    uri = f"postgresql+psycopg2://{bd['user']}:{bd['password']}@{bd['host']}:{str(bd['port'])}/{bd['database']}"
    engine = sa.create_engine(
        uri,
        connect_args={'options': '-csearch_path={}'.format(bd['schema'])}
        )
    return engine

class Report:

    def __init__(self, method, periodo, controller, path, bd):
        self.__method = method
        self.__periodo = periodo
        self.__controller = controller
        self.__path = path
        self.__client = httpx.Client()
        self.__data = None
        self.__bd = bd

    def get_url(self):
        return "https://" + self.__controller + self.__path + f"?ano={self.get_ano_referencia()}&mes={self.get_mes_referencia()}"

    def get_method(self):
        return self.__method

    def get_ano_referencia(self):
        return self._get_data_referencia().year

    def get_mes_referencia(self):
        return self._get_data_referencia().month

    def _get_data_referencia(self):
        return date.today() - relativedelta(months=self.__periodo)

    def requisitaApi(self):
        url = self.get_url()
        print(F"URL: {url}")
        headersList = {}
        dados =  self.__client.get(url, headers=headersList)
        self.__data = dados

    def parseJson(self):
        dadosDict = xmltodict.parse(self.__data.text)
        dadosJson = json.loads(dadosDict['string']['#text'])
        df = pd.DataFrame(dadosJson)
        return df

    def insereDados(self):
        df = self.parseJson()
        engine = criaEngine(self.__bd)
        print("Inserindo dados no banco de dados...")
        df['data_criacao_registro'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        df.to_sql(f"{str(self.__path).replace('/','')}", con=engine, if_exists='replace', index=False)
        print("Dados inseridos com sucesso!")
        engine.dispose()

    def run(self):
        self.requisitaApi()
        self.insereDados()


if __name__ == '__main__':

    from time import sleep

    with open('config.yaml') as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    _CONTROLLER = config['controller']
    _METHOD = config['method']
    _PERIODO = int(config['months'])
    _PATHS = list(config['paths'].values())
    _BD = config['bd']

    for rota in _PATHS:
        print(f"Requisitando a Rota: '{rota}'")
        report = Report(
            method=_METHOD,
            periodo=_PERIODO,
            controller=_CONTROLLER,
            path=rota,
            bd=_BD)
        report.run()
        print(f"Rota '{rota}' requisitada com sucesso! Aguardando 60 segundos para a próxima requisição...'")
        sleep(60)







