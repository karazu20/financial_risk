"""financial_risk URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.11/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url, include
from django.contrib import admin
from django.contrib.auth.views import login, logout_then_login

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^financial_risk/portal/', include('portal.urls', namespace='portal')),
    url(r'^financial_risk/rcs_contributions/', include('rcs_contributions.urls', namespace='rcs_contributions')),
    url(r'^financial_risk/rcs_optimization/', include('rcs_optimization.urls', namespace='rcs_optimization')),
    url(r'^financial_risk/dummy/', include('dummy.urls', namespace='dummy')),
    #url(r'^financial_risk/rcs_sensitivity/', include('rcs_sensitivity.urls', namespace='rcs_sensitivity')),
    url(r'^financial_risk/stress_sensitivity/', include('stress_sensitivity.urls', namespace='stress_sensitivity')),    
    url(r'^$', login, {'template_name':'portal/login.html'}, name='login'),
    url(r'^logout/', logout_then_login, name='logout'),  
]
