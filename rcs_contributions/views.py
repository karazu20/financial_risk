# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from rcs_contributions.middleware import *
from rcs_contributions.models import *
from rcs_contributions.forms import *
#from middleware import *



# Create your views here.
@login_required
def main(request):	
	print 'estoy en rcs'	
	if request.method == 'POST':
		form_rcs = RCSForm(request.POST)
		if form_rcs.is_valid():
			
			rcs=form_rcs.save()
			execute_rcs(rcs)			
			return redirect('rcs_contributions:success')
		else:
			print 'datos invalidos'
			return render(request, 'rcs_contributions/main.html', {'form': form_rcs})
	else:		
		form_rcs = RCSForm()
		return render(request, 'rcs_contributions/main.html', {'form': form_rcs})


@login_required
def success(request):
	return render(request, 'rcs_contributions/success.html')
