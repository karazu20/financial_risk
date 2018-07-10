# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User

ESTATUS = {
	(1,'Pendiente'),
	(2,'En Proceso'),
	(3,'Finalizado'),
	(4,'Fallido'),
}

TYPE_ANALISYS={
 	
 	(1,"Cartera Inversiones Base"), 
 	(2, "Captura Instrumento")
}


class RCS(models.Model):
	folio = models.IntegerField(null=True)
	owner = models.ForeignKey(User, related_name='owner', null=True)
	date_insert = models.DateTimeField(default=timezone.now)
	date_update = models.DateTimeField(default=timezone.now)
	date_init = models.DateTimeField(verbose_name='Fecha de inicio',  null=True)
	date_end = models.DateTimeField(verbose_name='Fecha de fin', null=True)
	estatus = models.IntegerField(default=1, choices=ESTATUS)
	type_analisys = models.IntegerField(default=1, choices=TYPE_ANALISYS)
	#SIM.mat, LYOT.mat, LYLP.mat, AUX.mat, REF.mat, CAT.xlsx, VEC.xlsx)
	fecha_corte = models.DateTimeField(default=timezone.now)
	numero_escenarios = models.IntegerField(null=True)
	costo_capital= models.FloatField(null=True)
	inflacion= models.FloatField(null=True)
	reprocesar= models.BooleanField(default=False)
	complementos= models.BooleanField(default=False)

	sim = models.FileField(
		verbose_name='SIM.mat',
		blank=True,
		null=True,
		upload_to='charges_files',
	)
	lyot = models.FileField(
		verbose_name='LYOT.mat',
		blank=True,
		null=True,
		upload_to='charges_files',
	)
	lylp = models.FileField(
		verbose_name='LYLP.mat',
		blank=True,
		null=True,
		upload_to='charges_files',
	)
	aux = models.FileField(
		verbose_name='AUX.mat',
		blank=True,
		null=True,
		upload_to='charges_files',
	)
	ref = models.FileField(
		verbose_name='REF.mat',
		blank=True,
		null=True,
		upload_to='charges_files',
	)
	cat = models.FileField(
		verbose_name='CAT.xlsx',
		blank=True,
		null=True,
		upload_to='charges_files',
	)
	vec = models.FileField(
		verbose_name='VEC.xlsx',
		blank=True,
		null=True,
		upload_to='charges_files',
	)

	def __str__(self):
		return str (self.id) + " - " + str (self.folio) + " - " + str (self.costo_capital)
	
	