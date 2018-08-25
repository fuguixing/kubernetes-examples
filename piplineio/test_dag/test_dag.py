from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'wazza',
    'depends_on_past': False,
    'start_date': datetime.now(),
    'email': ['eugene.tenkaev@gmail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG('test_dag', default_args=default_args)

t1 = BashOperator(
    task_id='gauss',
    bash_command='Rscript /root/r_scripts/run_gauss_v2.R',
    dag=dag)