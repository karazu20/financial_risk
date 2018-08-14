# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render


def main(request):
	print 'en dummy'
	return render(request, 'rcs_optimization/main.html', {})

# Create your views here.
