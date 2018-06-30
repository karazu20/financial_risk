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




#Params gmail server and email accounts
mail_server = 'smtp.gmail.com:587'
from_addr = 'karazu20@gmail.com'
to_addr = [ 'link_df17@hotmail.com']
    
# Credentials email
username = 'karazu20@gmail.com'
password = 'cbi%1985'




def send_mail ():  
    themsg = MIMEMultipart('alternative')
    themsg['Subject'] = 'Resultados de Riesgos financieros'
    themsg['To'] = ", ".join(to_addr)
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
                        %s
                    </p>
                <br>
                <p>
                    Gracias!!.
                </p>
                
            </body>
        </html>
    ''' % ("Ejecucion RCS", "google.com.mx")

    part2 = MIMEText(html, 'html', 'utf-8')
    themsg.attach(part2)
    server = smtplib.SMTP(mail_server)
    server.ehlo()
    server.starttls()
    server.login(username,password)
    server.sendmail(from_addr, to_addr, str(themsg))
    server.quit()

    print 'Email ok'
