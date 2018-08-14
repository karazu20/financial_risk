# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class Stress(models.Model):
	a = models.IntegerField(null=True)
	b = models.IntegerField(null=True)
	c = models.IntegerField(null=True)
	#res = models.IntegerField(null=True)
