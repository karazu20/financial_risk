# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
#from middleware import *

# Create your views here.
#login_required
def index(request):	
	print 'estoyr en rcs'	
	contexto={}	
	#rcs_var = RCS()
	#execute_sub_1('hola','sofi')
	return render(request, 'rcs_contribution/index.html', contexto)