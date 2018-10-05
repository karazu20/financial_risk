from celery.decorators import task
import time
from rcs_sensitivity.middleware import *
from financial_risk.utils import *
from django.conf import settings
from rcs_sensitivity.models import RCSSen, ResultRCSSen
import datetime


COMPLETA = 2
ERROR = 3

@task(name="execute_rcs_sen")
def exe_analisis(param):
    print ('Execute task rcs sensitivity')  
    path_results = execute_rcs_sen(param)  
    result = ResultRCSSen()
    rcs_sen = RCSSen.objects.get( pk = param['id'])
    today_date = datetime.date.today().strftime("%m/%d/%Y")                      
    result.folio = str (rcs_sen.id) + "-" + today_date
    result.rcs_sen = rcs_sen
    result.path = settings.MEDIA_ROOT + 'user_{0}/sensitivity/{1}'.format(rcs_sen.owner.username, "results") 
    out = zip_out(settings.MEDIA_ROOT + 'user_{0}/sensitivity/'.format(rcs_sen.owner.username) , result.path)
    result.zip_file = out
    result.save()
    url_result =  "rcs_sensitivity/results/{0}/".format(result.id)
    send_mail(param['email'], url_result)




