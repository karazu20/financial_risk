# -*- coding: utf-8 -*-

# Create your calls to matlab here.
import matlab.engine
import os
print "me ejcuto al inicio"


def execute_rcs(rcs):
    print "en execute_rcs"
    print rcs
    os.chdir("/media/sf_Herramientas_RCS/ContribucionRCSActivos_Allianz")
    eng = matlab.engine.start_matlab()
    #rcs = {'dir': '/media/sf_Herramientas_RCS/ContribucionRCSActivos_Allianz', 
    #				'fechacorte': '20170331', 'numEscenarios': '10000', 'costoCapital': '0.15', 'inflacion': '0.05'}
    ret = eng.contMargRCSfun(rcs)
    print ret
    print "exit call" 


#execute_rcs()
