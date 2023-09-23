from typing import List
from datetime import datetime, timedelta
from crawler import main
from airflow.decorators import task, dag

@task.python
def executaCrawler():
    print("Executando o crawler...")
    main()
    print("Crawler executado com sucesso!")

@task()
def dbtRun():
    comando: str = "cd /opt/airflow/dbt/etl && dbt deps && dbt run -t prod"
    print(f"Executando o comando <{comando}>")
    import subprocess
    resultado: subprocess.CompletedProcess = subprocess.run(comando, shell=True, capture_output=True, text=True)
    if int(resultado.returncode) != 0:
        raise Exception(f"Falha ao executar o comando dbt run. \nErro:  {resultado.stdout}")

@dag(
    dag_id="etl",
    description="ETL de dados do projeto de despesas",
    start_date=datetime(2022, 9, 14),
    schedule_interval=None,
    tags=["meu teste", "teste"],
    catchup=False
)
def dag_etl():

    # executaCrawler() >> dbtRun()
    dbtRun()

dag_etl = dag_etl()