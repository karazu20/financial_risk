# -*- coding: utf-8 -*-

# Create your calls to matlab here.
#import matlab.engine
import os
print "me ejcuto al inicio"


def execute_rcs(rcs):
    print "en execute_rcs"
    print rcs
    os.chdir("/home/duraznito/risk_project/financial_risk/rcs_contributions/ContribucionRCSActivos_Allianz")
    #eng = matlab.engine.start_matlab()
    paramRCS = {'dir': '/home/duraznito/risk_project/financial_risk/rcs_contributions/ContribucionRCSActivos_Allianz/', 
    				'fechacorte': '20170331', 'numEscenarios': '100000', 'costoCapital': '0.15', 'inflacion': '0.05'}
    #ret = eng.contMargRCSfun(paramRCS)

    #print ret
    print "exit call" 


#execute_rcs()
