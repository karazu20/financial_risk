# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django import forms
from django.forms import ModelForm
from portal.models import *
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext_lazy as _


def validate_password_strength(value):
	"""Validates that a password is as least 10 characters long and has at least
	2 digits and 1 Upper case letter.
	"""
	min_length = 4
	print 'validacion password'
	print value
	if len(value) < min_length:
		raise ValidationError(_('Password must be at least {0} characters '
								'long.').format(min_length))	
	return value


def validate_password_two(pass1, pass2):

	if pass1!=pass2:
		raise ValidationError(_('Confirmation Passwords not is correct.'))
	else:
		return pass2

class UserCreateForm(UserCreationForm):

	class Meta:
		model = User

		fields = [
				"username",
			#	"email",
				"password1",
				"password2",
		]
		labels = {
			'username': 'Username',
			#'email': '',
			'password1': 'Password',
			'password2': 'Confirme Password',
		}
		widgets = {
			'username': forms.TextInput(attrs={'placeholder':"Username", 'class':'validate'}),			
			'password1': forms.PasswordInput(attrs={'placeholder':'Minimo 8 caracteres', 'class':'validate' }),
			'password2': forms.PasswordInput(attrs={'placeholder':'Confirme su password','class':'validate'}),
		}

	def clean_password1(self):
		return validate_password_strength(self.cleaned_data['password1'])

	def clean_password2(self):
		try:
			return validate_password_two(self.cleaned_data['password1'], self.cleaned_data['password2'])
		except  KeyError:
			raise ValidationError(_('Not validate Password'))

