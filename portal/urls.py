from django.conf.urls import url, include
from portal.views import *





urlpatterns = [
    url(r'^$', index, name='index'), 
    #url(r'^$', login, {'template_name':'portal:login.html'}, name='login'),
    #url(r'^logout/', logout_then_login, name='logout'),  
] 
