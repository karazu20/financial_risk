from django.conf.urls import url
from rcs_optimization.views import *



urlpatterns = [
    url(r'^$', main, name='main'), 

] 
