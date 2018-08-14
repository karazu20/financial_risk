from django.conf.urls import url
from stress_sensitivity.views import *



urlpatterns = [
    url(r'^$', main, name='main'),
    url(r'^main_uno$', main_uno, name='main_uno'), 

] 
