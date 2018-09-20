from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic import TemplateView

class DownloadResult(LoginRequiredMixin, TemplateView): 
    
    template_name = "rcs_contributions/main.html"
    #optional
    login_url = "/"
    redirect_field_name = "login"    
    raise_exception = False

    def get(self, request):
        return self.render_to_response({})

class Test(TemplateView): 
    
    template_name = "base/base2.html"    
    def get(self, request):
        return self.render_to_response({})