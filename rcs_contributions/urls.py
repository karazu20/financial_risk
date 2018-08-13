from django.conf.urls import url
from rcs_contributions.views import *



urlpatterns = [
    url(r'^$', main, name='main'), 
    url(r'^$success', success, name='success'), 
    url(r'^download$', download_zip, name='download_zip'),

] 
