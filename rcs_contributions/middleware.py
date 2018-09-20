# -*- coding: utf-8 -*-

# Create your calls to matlab here.
#import matlab.engine
import os
print "me ejcuto al inicio"


def execute_rcs(rcs):
    print "en execute_rcs"
    print rcs
    os.chdir("/media/sf_Herramientas_RCS/ContribucionRCSActivos_Allianz")
    eng = matlab.engine.start_matlab()    
    ret = eng.contMargRCSfun(rcs)
    print ret
    print "exit call" 


#execute_rcs()
