FROM apache/airflow:2.7.1
COPY requirements.txt /

ENV DB_TCC_HOST "dw"
ENV DB_TCC_USER "julio"
ENV DB_TCC_PASS "julio"
ENV DB_TCC_DBNAME "despesas"
ENV DB_TCC_PORT 5432
ENV DB_TCC_SCHEMA "raw"
ENV TCC_CONTROLLER "trescoracoes-mg.portaltp.com.br/api/transparencia.asmx"
ENV TCC_PERIODO 2

RUN pip install --no-cache-dir -r /requirements.txt