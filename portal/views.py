# -*- coding: utf-8 -*-
from __future__ import unicode_literals


from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from portal.models import *
from portal.forms import *
from django.contrib.auth import authenticate, login


# Create your views here.
@login_required
def index(request):	
	contexto={}	
	return render(request, 'portal/index.html', contexto)
