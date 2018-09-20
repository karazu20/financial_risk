# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from stress_sensitivity.forms import *
#from middleware import *

# Create your views here.

def suma(a,b,c):
	return(a+b+c)

@login_required
def main(request):	
	print ('estoyr en stress sensitivity')
	#print('el resultado es', suma(1,2,3))
	#form_stress = StressForm()
	#strss=form_stress.save()
	#return a*b
	#print d
	if request.method == 'POST':
		form_stress = StressForm(request.POST)
		if form_stress.is_valid():
			strss=form_stress.save()
			#paramSt = {
			#			'a': strss.a, 
    		#			'b': strss.b,
    		#			'c': strss.c}
			#res = paramSt['b']+paramSt['a']+paramSt['c']
			#print res
			#context = {'name':res}
			#return render (request,'stress_sensitivity/Result1.html',{context})
			res =  suma(strss.a,strss.b,strss.c)
			return render (request,'stress_sensitivity/Result1.html',{'resultado': res})
			

			#d=strss.a*strss.b
	#		print d
			#exe_calculate.delay(paramRCS)
			#execute_rcs(rcs)			
		else:
			print ('datos invalidos')
			return render(request, 'stress_sensitivity/main.html', {'form': form_stress})
	else:		
		form_stress = StressForm()
		return render(request, 'stress_sensitivity/main.html', {'form': form_stress})
	return render(request, 'stress_sensitivity/main.html', {})


def main_uno(request):	
	print ('estoyr en sensitivity')
	contexto={}		
	return render(request, 'stress_sensitivity/main1.html', {})

def resultado(request):	
	print ('estoy en en resulatdo de la suma')
	return render(request, 'stress_sensitivity/Result1.html', {'content':['If you want to conctact','1']})