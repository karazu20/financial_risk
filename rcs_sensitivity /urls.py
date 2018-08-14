from django.conf.urls import url
from rcs_sensitivity.views import *



urlpatterns = [
    url(r'^$', main, name='main'), 

] 
