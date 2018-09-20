from celery.decorators import task
import time
from rcs_contributions.middleware import *
from rcs_contributions.messages_utils import *
from django.conf import settings


COMPLETA = 2
ERROR = 3
@task(name="sum_two_numbers")
def add(x, y):
	time.sleep(10)
	#print 'in task'
	for i in range (100):
		x=i+x
		y = i + y*i
		#print i

	return x + y


@task(name="execute_task")
def exe_calculate(rcs):
	print ('Execute task')
	
	execute_rcs(rcs)
	 
	out = zip_out("", settings.PATH_FILES + "/ResultadosSalida")
	send_mail(rcs['email'])



