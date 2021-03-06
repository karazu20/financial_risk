# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django import forms
from django.forms import ModelForm
from rcs_contributions.models import *
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext_lazy as _


class RCSForm(forms.ModelForm):

	class Meta:
		model = RCS

		fields = [				
				"sim",
				"lyot",
				"lylp",
				"aux",
				"ref",
				"cat",
				"vec",
				"type_analisys",
				"fecha_corte",
				"numero_escenarios",
				"costo_capital",
				"inflacion",
				"reprocesar",
				"complementos",
				

		]
		labels = {
				"sim":"SIM mat",
				"lyot":"LYOT mat",
				"lylp":"LYLP mat",
				"aux":"AUX mat",
				"ref":"REF mat",
				"cat":"CAT xlsx",
				"vec":"VEC xlsx",
				"type_analisys":"Tipo de analisis",
				"fecha_corte":"Fecha de corte",
				"numero_escenarios": "Número de escenarios",
				"costo_capital": "Costo Capital",
				"inflacion": "Inflación",
				"reprocesar": "Reporcesar",
				"complementos": "Complementos",
		}
		widgets = {
			'sim': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'lyot': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'lylp': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'aux': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'ref': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'cat': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'vec': forms.FileInput(attrs={ "accept":".xls,.xlsx"}),
			'type_analisys': forms.Select(),
			"fecha_corte":forms.DateInput(attrs={ 'class':'datepicker'}),
			"numero_escenarios":forms.TextInput(),
			"costo_capital":forms.TextInput(),
			"inflacion":forms.TextInput(),
			"reprocesar":forms.CheckboxInput(attrs={ 'class':'filled-in'}),
			"complementos":forms.CheckboxInput(attrs={ 'class':'filled-in'}),			
		}

		"""input_formats={

			'fecha_corte': ['%d/%m/%Y','%m/%d/%Y']

		}"""
