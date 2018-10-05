from celery.decorators import task
import time
from rcs_contributions.middleware import *
from financial_risk.utils import *
from django.conf import settings
from rcs_contributions.models import RCS, ResultRCS
import datetime


COMPLETA = 2
ERROR = 3


@task(name="execute_rcs")
def exe_analisis(param):
    print ('Execute rcs')    
    path_results = execute_rcs(param)     
    result = ResultRCS()
    rcs = RCS.objects.get( pk = param['id'])
    today_date = datetime.date.today().strftime("%m/%d/%Y")                         
    result.folio = str (rcs.id) + "-" + today_date
    result.rcs = rcs
    result.path = settings.MEDIA_ROOT + 'user_{0}/contributions/{1}'.format(rcs.owner.username, "results") 
    out = zip_out(settings.MEDIA_ROOT + 'user_{0}/contributions/'.format(rcs.owner.username) , result.path)
    result.zip_file = out
    result.save()
    url_result =  "rcs_contributions/results/{0}/".format(result.id)
    send_mail(param['email'], url_result)
