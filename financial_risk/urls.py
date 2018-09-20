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
from django.urls import include, path
from django.contrib import admin
from django.contrib.auth import views as auth_views
from django.contrib.auth.views import LoginView, logout_then_login
from financial_risk.views import Test

urlpatterns = [
    path('admin/', admin.site.urls),
    path('financial_risk/portal/', include('portal.urls')),
    path('financial_risk/rcs_contributions/', include('rcs_contributions.urls')),
    path('financial_risk/rcs_optimization/', include('rcs_optimization.urls')),    
    path('financial_risk/stress_sensitivity/', include('stress_sensitivity.urls')),    
    path('', LoginView.as_view(template_name='portal/login.html'), name='login'),
    path('test/', Test.as_view(), name='test_template'),
    path('logout/', logout_then_login, name='logout'),  
]
