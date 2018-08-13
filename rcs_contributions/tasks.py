from celery.decorators import task
import time
from rcs_contributions.middleware import *
from rcs_contributions.messages_utils import *


COMPLETA = 2
ERROR = 3
@task(name="sum_two_numbers")
def add(x, y):
	time.sleep(10)
	#print 'in task'
	for i in range (100):
		x=i+x
		y = i + y*i
		print i

	return x + y


@task(name="execute_task")
def exe_calculate(rcs):
	print 'Execute task'
	print rcs
	#for i in range(100000):
	#				print i 
	execute_rcs(rcs)
	zip_out("","")
	send_mail()



