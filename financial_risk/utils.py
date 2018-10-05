# -*- coding: utf-8 -*-
import datetime
import smtplib
from email.mime.text import MIMEText
from email import encoders
from email.message import Message
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
import os
import time
import shutil
from django.conf import settings


#Params gmail server and email accounts
mail_server = 'smtp.gmail.com:587'
from_addr = 'karazu20@gmail.com'
#to_addr = [ 'adan_dh@yahoo.com.mx']
    
# Credentials email
username = 'karazu20@gmail.com'
password = 'cbi%1985'




def send_mail (email, result):  
    themsg = MIMEMultipart()
    themsg['Subject'] = 'Resultados de Riesgos financieros'
    themsg['To'] = email #", ".join(to_addr)
    themsg['From'] = from_addr
    html = '''
        <html>
            <head></head>
            <body>
                
                <br>
                <h3>El Análisis ha terminado %s</h3>
                <br>
                <p>
                    Puede ver los resultados y descargarlos en la siguienre liga:
                </p>
                
                <br>
                    <p>
                        <a href="%s">Resultados</href>
                    </p>
                <br>
                <p>
                    Gracias!!.
                </p>
                
            </body>
        </html>
    ''' % ("Ejecucion de análisis", "http://127.0.0.1:8000/financial_risk/" + result)

    part1 = MIMEText(html, 'html', 'utf-8')
    themsg.attach(part1)    
    server = smtplib.SMTP(mail_server)
    server.ehlo()
    server.starttls()
    server.login(username,password)
    server.sendmail(from_addr, email, str(themsg))
    server.quit()

    print ('Email ok')

def zip_out(path_out, path_in):
    out = path_out + "out"
    shutil.make_archive(out, 'zip', path_in)
    return out + ".zip"
