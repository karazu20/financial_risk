from django.conf.urls import url
from dummy.views import *



urlpatterns = [
    url(r'^$', main, name='main'), 

] 
