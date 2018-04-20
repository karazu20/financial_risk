from django.conf.urls import url
from stress_sensitivity.views import *



urlpatterns = [
    url(r'^$', main, name='main'), 

] 
