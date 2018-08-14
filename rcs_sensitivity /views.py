# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.contrib.auth.decorators import login_required
#from middleware import *

# Create your views here.
@login_required
def main(request):	
	print 'estoy en rcs sensitivity'	
	contexto={}		
	return render(request, 'rcs_sensitivity/main.html', contexto)
