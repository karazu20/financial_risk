# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django import forms
from django.forms import ModelForm
from rcs_sensitivity.models import *
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext_lazy as _


class RCSSenForm(forms.ModelForm):

    class Meta:
        model = RCSSen

        fields = [              
                "sim",
                "fecha_corte",
                "numero_escenarios",
        ]
        labels = {
                "sim":"SIM mat",                
                "fecha_corte":"Fecha de corte",
                "numero_escenarios": "Número de escenarios",
                
        }
        widgets = {
            'sim': forms.FileInput(attrs={ "accept":".pdf"}),            
            "fecha_corte":forms.DateInput(attrs={ 'class':'datepicker'}),
            "numero_escenarios":forms.TextInput(),
            
        }


