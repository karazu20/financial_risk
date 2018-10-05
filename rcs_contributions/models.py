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


def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/user_<id>/<filename>
    print ( (instance, filename))
    return 'user_{0}/contributions/{1}'.format(instance.owner.username, filename)


class RCS(models.Model):
	folio = models.CharField(max_length=100, null=False)
	owner = models.ForeignKey(User, related_name='rcs_owner', null=True, on_delete=models.CASCADE)
	date_insert = models.DateTimeField(default=timezone.now)
	date_update = models.DateTimeField(default=timezone.now)
	date_init = models.DateTimeField(verbose_name='Fecha de inicio',  null=True)
	date_end = models.DateTimeField(verbose_name='Fecha de fin', null=True)
	estatus = models.IntegerField(default=1, choices=ESTATUS)
	type_analisys = models.IntegerField(default=1, choices=TYPE_ANALISYS)	
	fecha_corte = models.DateTimeField(default=timezone.now)
	numero_escenarios = models.IntegerField(null=True)
	costo_capital= models.FloatField(null=True)
	inflacion= models.FloatField(null=True)
	reprocesar= models.BooleanField(default=False)
	complementos= models.BooleanField(default=False)

	sim = models.FileField(
		upload_to=user_directory_path,	                      
		verbose_name='SIM.mat',
		blank=True,
		null=True,
		
	)
	lyot = models.FileField(
	    upload_to=user_directory_path,
		verbose_name='LYOT.mat',
		blank=True,
		null=True,
		
	)
	lylp = models.FileField(
		upload_to=user_directory_path,	                        
		verbose_name='LYLP.mat',
		blank=True,
		null=True,
		
	)
	aux = models.FileField(
		upload_to=user_directory_path,	                       
		verbose_name='AUX.mat',
		blank=True,
		null=True,
		
	)
	ref = models.FileField(
		upload_to=user_directory_path,	                       
		verbose_name='REF.mat',
		blank=True,
		null=True,		
	)
	cat = models.FileField(
	    upload_to=user_directory_path,
		verbose_name='CAT.xlsx',
		blank=True,
		null=True,		
	)
	vec = models.FileField(
		upload_to=user_directory_path,	                       
		verbose_name='VEC.xlsx',
		blank=True,
		null=True,		
	)

	def __str__(self):
		return str (self.owner.username) + " - " + str (self.id) + " - " + str (self.folio) 
	
	

class ResultRCS (models.Model):
	folio = models.CharField(max_length=100, null=False)
	rcs = models.ForeignKey(RCS, related_name='rcs', null=True, on_delete=models.CASCADE)
	path = models.CharField(max_length=100, null=False)
	date_create = models.DateTimeField(default=timezone.now)
	