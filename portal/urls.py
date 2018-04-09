from django.conf.urls import url, include
from portal.views import *
from django.contrib.auth.decorators import login_required
from django.contrib.auth.views import login, logout_then_login



urlpatterns = [
    url(r'^$', index, name='index'), 
    #url(r'^$', login, {'template_name':'portal:login.html'}, name='login'),
    #url(r'^logout/', logout_then_login, name='logout'),  
] 
