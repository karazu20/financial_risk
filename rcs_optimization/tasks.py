from celery.decorators import task
import time
from rcs_optimization.middleware import *
from financial_risk.utils import *
from django.conf import settings
from rcs_optimization.models import RCSOpt, ResultRCSOpt
import datetime


COMPLETA = 2
ERROR = 3

@task(name="execute_rcs_opt")
def exe_analisis(param):
    print ('Execute task rcs optimizacion')  
    path_results = execute_rcs_opt(param)  
    result = ResultRCSOpt()
    rcs_opt = RCSOpt.objects.get( pk = param['id'])
    today_date = datetime.date.today().strftime("%m/%d/%Y")                      
    result.folio = str (rcs_opt.id) + "-" + today_date
    result.rcs_opt = rcs_opt    
    result.path = settings.MEDIA_ROOT + 'user_{0}/optimization/{1}'.format(rcs_opt.owner.username, "results") 
    out = zip_out(settings.MEDIA_ROOT + 'user_{0}/optimization/'.format(rcs_opt.owner.username) , result.path)
    result.zip_file = out
    result.save()    
    url_result =  "rcs_optimization/results/{0}/".format(result.id)
    send_mail(param['email'], url_result)






