# -*- coding: utf-8 -*-

# Create your calls to matlab here.
#import matlab.engine
import os


def execute_rcs(rcs):
    print ("Ejecutando el analisis")
    print (rcs)
    #os.chdir("/media/sf_Herramientas_RCS/ContribucionRCSActivos_Allianz")
    #eng = matlab.engine.start_matlab()    
    #ret = eng.contMargRCSfun(rcs)
    for i in range (0,10000):
        print (".....")
    
    print ("exit call" )
    return "salida"



