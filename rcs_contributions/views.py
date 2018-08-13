# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
#from rcs_contributions.middleware import *
from rcs_contributions.models import *
from rcs_contributions.forms import *
from rcs_contributions.tasks import *
#from middleware import *
from django.conf import settings
from django.http import HttpResponse


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
			print 'RCS valido'
			rcs=form_rcs.save()
			paramRCS = {
						'dir': settings.PATH_FILES, 
    					'fechacorte': '20170331', 
    					'numEscenarios': rcs.numero_escenarios, 
    					'costoCapital': rcs.costo_capital, 
    					'inflacion': rcs.inflacion}
			print paramRCS
			exe_calculate.delay(paramRCS)
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


def download_zip(request):
    zip_path = settings.PATH_RESULTS + "out.zip"
    zip_file =  open(zip_path, 'rb')
    response = HttpResponse(zip_file, content_type='application/zip')
    response['Content-Disposition'] = 'attachment; filename=%s' % 'A.zip'
    response['Content-Length'] = os.path.getsize(zip_path)
    zip_file.close()

    return response
