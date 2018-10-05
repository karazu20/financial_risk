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



def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/user_<id>/<filename>
    print ( (instance, filename))
    return 'user_{0}/optimization/{1}'.format(instance.owner.username, filename)




class RCSOpt(models.Model):
    folio = models.CharField(max_length=100, null=False)
    owner = models.ForeignKey(User, related_name='rcs_opt_owner', null=True, on_delete=models.CASCADE)
    date_insert = models.DateTimeField(default=timezone.now)
    date_update = models.DateTimeField(default=timezone.now)
    date_init = models.DateTimeField(verbose_name='Fecha de inicio',  null=True)
    date_end = models.DateTimeField(verbose_name='Fecha de fin', null=True)
    estatus = models.IntegerField(default=1, choices=ESTATUS)
    fecha_corte = models.DateTimeField(default=timezone.now)
    numero_escenarios = models.IntegerField(null=True)

    sim = models.FileField(
        upload_to=user_directory_path,                        
        verbose_name='SIM.mat',
        blank=True,
        null=True,
        
    )
    
    def __str__(self):
        return str (self.owner.username) + " - " + str (self.id) + " - " + str (self.folio) 
    
    

class ResultRCSOpt (models.Model):
    folio = models.CharField(max_length=100, null=False)
    rcs_opt = models.ForeignKey(RCSOpt, related_name='rcs', null=True, on_delete=models.CASCADE)
    path = models.CharField(max_length=100, null=False)
    zip_file = models.CharField(max_length=200, null=False)
    date_create = models.DateTimeField(default=timezone.now)    