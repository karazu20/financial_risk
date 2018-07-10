# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
#from rcs_contributions.middleware import *
from rcs_contributions.models import *
from rcs_contributions.forms import *
from rcs_contributions.tasks import *
#from middleware import *



# Create your views here.
@login_required
def main(request):	
	print 'estoy en rcs'	
	if request.method == 'POST':
		form_rcs = RCSForm(request.POST, request.FILES)
		#print request.POST
		print request.POST['fecha_corte']
		#print fecha
		#print form_rcs
		if form_rcs.is_valid():
			print 'sol procesada'
			rcs=form_rcs.save()
			#print rcs
			exe_calculate.delay("tarea a ejecutar")
			#execute_rcs(rcs)			
			return  render(request, 'rcs_contributions/success.html')
		else:
			print 'datos invalidos'
			return render(request, 'rcs_contributions/main.html', {'form': form_rcs})
	else:		
		form_rcs = RCSForm()
		return render(request, 'rcs_contributions/main.html', {'form': form_rcs})


@login_required
def success(request):
	return render(request, 'rcs_contributions/success.html')
