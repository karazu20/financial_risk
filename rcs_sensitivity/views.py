# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
#from rcs_contributions.middleware import *
from rcs_sensitivity.models import *
from rcs_sensitivity.forms import *
from rcs_sensitivity.tasks import *

#from middleware import *
from django.conf import settings
from django.http import HttpResponse
from django.contrib.auth import authenticate
import datetime


# Create your views here.
@login_required
def main(request):  
    print( 'estoy en rcs sentivity')
    user =request.user
    print (user)
    if request.method == 'POST':
        form_rcs = RCSSenForm(request.POST, request.FILES)     
        print (form_rcs)
        print (request.POST['fecha_corte']  )
        if form_rcs.is_valid():
            
            rcs_sen=form_rcs.save(commit=False)
            rcs_sen.owner = user
            today_date = datetime.date.today().strftime("%m/%d/%Y") 
            rcs_sen.folio = str (user.id) + "-" + today_date
            rcs_sen.save()
            print (rcs_sen.fecha_corte)
            
            paramRCS = {
                        'id':rcs_sen.id,
                        'fechacorte': '20170331', 
                        'numEscenarios': str (rcs_sen.numero_escenarios),                         
                        'email': user.email}
                        
            exe_analisis.delay(paramRCS)           
            return  render(request, 'portal/success.html')
        else:
            print ('datos invalidos')
            return render(request, 'rcs_sensitivity/main.html', {'form': form_rcs})
    else:       
        form_rcs = RCSSenForm()
        return render(request, 'rcs_sensitivity/main.html', {'form': form_rcs})


@login_required
def success(request):
    return render(request, 'portal/success.html')



def download_zip(request, id):
    print ("in results: " + str (id))
    if request.method == 'POST':
        us =  request.POST['username']
        passw =  request.POST['password']
        user = authenticate(username=us, password=passw)
        print ('in post')
        if user is not None:
            result = ResultRCSSen.objects.get( pk = id)
            zip_path = result.zip_file
            zip_file =  open(zip_path, 'rb')
            response = HttpResponse(zip_file, content_type='application/zip')
            response['Content-Disposition'] = 'attachment; filename=%s' % 'resultados.zip'
            response['Content-Length'] = os.path.getsize(zip_path)
            zip_file.close()
            return response
        else:
            return render(request, 'rcs_sensitivity/login.html')

    else:                
        return render(request, 'rcs_sensitivity/login.html')

