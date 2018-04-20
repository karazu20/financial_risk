# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.contrib.auth.decorators import login_required
#from middleware import *

# Create your views here.
@login_required
def main(request):	
	print 'estoyr en rcs'	
	contexto={}	
	#rcs_var = RCS()
	#execute_sub_1('hola','sofi')
	return render(request, 'rcs_contributions/main.html', contexto)