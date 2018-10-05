# Risk

Proyecto de riesgos financieros

## Prerrequisitos
- Python 3.5
- virtualenv
- python-pip


## Configuración
```
$ virtualenv -p python3 .env
$ source .env/bin/activate
```

## Instalación
### Dependencias
```
$ pip install -r requirements.txt
$ apt-get install -y erlang
$ apt-get install rabbitmq-server

```

## Rabbit MQ
```
$ sudo systemctl enable rabbitmq-server
$ sudo systemctl start rabbitmq-server

```


## Celery
```
$ celery -A financial_risk worker -l info

```


## Crear BD
```
python manage.py makemigrations
python manage.py migrate
```


## Ejucutar
```
python manage.py runserver
```
 