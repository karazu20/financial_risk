# -*- coding: utf-8 -*-

# Create your calls to matlab here.
#import matlab.engine
import os
from rcs_sensitivity.analisis import analisis_uno


def execute_rcs_sen(rcs_sen):
    print ("en execute_rcs_sen")
    print (rcs_sen)    
    analisis_uno.rcs_uno(rcs_sen)
    print ("exit call" )
    return "salida"

