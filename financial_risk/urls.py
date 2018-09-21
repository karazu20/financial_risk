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
from django.contrib.auth.views import LoginView, logout_then_login
from financial_risk.views import Test

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^financial_risk/portal/', include(('portal.urls', 'portal'), namespace='portal')),
    url(r'^financial_risk/rcs_contributions/', include(('rcs_contributions.urls','rcs_contributions'), namespace='rcs_contributions' )),
    url(r'^financial_risk/rcs_optimization/', include(('rcs_optimization.urls', 'rcs_optimization'), namespace= 'rcs_optimization')),    
    url(r'^financial_risk/stress_sensitivity/', include(('stress_sensitivity.urls', 'stress_sensitivity'), namespace= 'stress_sensitivity')),    
    url(r'^', LoginView.as_view(template_name='portal/login.html'), name='login'),
    url(r'^test/', Test.as_view(), name='test_template'),
    url(r'^logout/', logout_then_login, name='logout'),  


]
