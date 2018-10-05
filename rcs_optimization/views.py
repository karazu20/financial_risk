# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
#from rcs_contributions.middleware import *
from rcs_optimization.models import *
from rcs_optimization.forms import *
from rcs_optimization.tasks import *

#from middleware import *
from django.conf import settings
from django.http import HttpResponse
from django.contrib.auth import authenticate
import datetime


# Create your views here.
@login_required
def main(request):  
    print( 'estoy en rcs optimizacion')
    user =request.user
    if request.method == 'POST':
        form_rcs = RCSOptForm(request.POST, request.FILES)     
        print (request.POST['fecha_corte']  )
        if form_rcs.is_valid():
            
            rcs_opt=form_rcs.save(commit=False)
            rcs_opt.owner = user
            today_date = datetime.date.today().strftime("%m/%d/%Y") 
            rcs_opt.folio = str (user.id) + "-" + today_date
            rcs_opt.save()
            print (rcs_opt.fecha_corte)
            
            paramRCS = {
                        'id':rcs_opt.id,
                        'fechacorte': '20170331', 
                        'numEscenarios': str (rcs_opt.numero_escenarios),                         
                        'email': user.email}
                        
            exe_analisis.delay(paramRCS)           
            return  render(request, 'portal/success.html')
        else:
            print ('datos invalidos')
            return render(request, 'rcs_optimization/main.html', {'form': form_rcs})
    else:       
        form_rcs = RCSOptForm()
        return render(request, 'rcs_optimization/main.html', {'form': form_rcs})


@login_required
def success(request):
    return render(request, 'portal/success.html')



def download_zip(request, id):
    print ("in results contributions: " + str (id))
    if request.method == 'POST':
        us =  request.POST['username']
        passw =  request.POST['password']
        user = authenticate(username=us, password=passw)
        if user is not None:
            result = ResultRCSOpt.objects.get( pk = id)
            zip_path = result.zip_file            
            zip_file =  open(zip_path, 'rb')
            response = HttpResponse(zip_file, content_type='application/zip')
            response['Content-Disposition'] = 'attachment; filename=%s' % 'resultados.zip'
            response['Content-Length'] = os.path.getsize(zip_path)
            zip_file.close()
            return response
        else:
            return render(request, 'rcs_optimization/login.html')

    else:                
        return render(request, 'rcs_optimization/login.html')

