from django.conf.urls import url
from rcs_contributions.views import *



urlpatterns = [
    url(r'^$', main, name='main'), 
    url(r'^$', success, name='success'), 

] 
