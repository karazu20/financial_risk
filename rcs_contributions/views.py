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
from django.contrib.auth import authenticate
import datetime

# Create your views here.
@login_required
def main(request):    
    print( 'estoy en rcs')
    user =request.user
    if request.method == 'POST':
        form_rcs = RCSForm(request.POST, request.FILES)        
        print (request.POST['fecha_corte'])        
        if form_rcs.is_valid():
            print( 'RCS valido')
            rcs=form_rcs.save(commit=False)
            rcs.owner = user
            today_date = datetime.date.today().strftime("%m/%d/%Y") 
            rcs.folio = str (user.id) + "-" + today_date
            rcs.save()

            print (rcs.fecha_corte)
            print (rcs.sim)
            paramRCS = {
                        'id':rcs.id,
                        'dir': settings.PATH_FILES, 
                        'fechacorte': '20170331', 
                        'numEscenarios': str (rcs.numero_escenarios), 
                        'costoCapital': str(rcs.costo_capital), 
                        'inflacion': str(rcs.inflacion),
                        'email': user.email}
                        
            exe_analisis.delay(paramRCS)            
            return  render(request, 'portal/success.html')
        else:
            print ('datos invalidos')
            return render(request, 'rcs_contributions/main.html', {'form': form_rcs})
    else:        
        form_rcs = RCSForm()
        return render(request, 'rcs_contributions/main.html', {'form': form_rcs})


@login_required
def success(request):
    return render(request, 'portal/success.html')


@login_required
def results(request):
    return render(request, 'portal/success.html')





def download_zip(request, id):
    print ("in results contributions: " + str (id))
    if request.method == 'POST':
        us =  request.POST['username']
        passw =  request.POST['password']
        user = authenticate(username=us, password=passw)
        if user is not None:
            result = ResultRCS.objects.get( pk = id)
            zip_path = result.zip_file            
            zip_file =  open(zip_path, 'rb')
            response = HttpResponse(zip_file, content_type='application/zip')
            response['Content-Disposition'] = 'attachment; filename=%s' % 'resultados.zip'
            response['Content-Length'] = os.path.getsize(zip_path)
            zip_file.close()
            return response
        else:
            return render(request, 'rcs_contributions/login.html')

    else:                
        return render(request, 'rcs_contributions/login.html')
