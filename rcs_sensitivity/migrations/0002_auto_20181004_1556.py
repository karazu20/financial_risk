# Generated by Django 2.1.1 on 2018-10-04 20:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('rcs_sensitivity', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='rcssen',
            name='estatus',
            field=models.IntegerField(choices=[(1, 'Pendiente'), (2, 'En Proceso'), (3, 'Finalizado'), (4, 'Fallido')], default=1),
        ),
        migrations.AlterField(
            model_name='rcssen',
            name='folio',
            field=models.CharField(default='sin folio', max_length=100),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='resultrcssen',
            name='folio',
            field=models.CharField(default='sin folio', max_length=100),
            preserve_default=False,
        ),
    ]