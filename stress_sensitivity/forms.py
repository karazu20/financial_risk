# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django import forms
from django.forms import ModelForm
from stress_sensitivity.models import *
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext_lazy as _


class StressForm(forms.ModelForm):

	class Meta:
		model = Stress
		fields = [				
				"a",
				"b",
				"c",
				#"res",				
		]
		labels = {
				"a":"Lado a",
				"b":"Lado b",
				"c":"Lado c",
				#"res": "Resultado",
		}
		widgets = {
			"a": forms.NumberInput(),
			"b": forms.NumberInput(),
			"c": forms.NumberInput(),
			#"res":forms.NumberInput(),
		}

		"""input_formats={

			'fecha_corte': ['%d/%m/%Y','%m/%d/%Y']

		}"""
