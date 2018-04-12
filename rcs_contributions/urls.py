from django.conf.urls import url
from rcs_contributions.views import *



urlpatterns = [
    url(r'^$', index, name='index'), 

] 
