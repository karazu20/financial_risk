function contMargRCS=contMargRCSfun(paramRCS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%HERRAMIENTA PARA EL ANALISIS DEL RCS DE ACTIVOS GRUPO FINANCIERO ASERTA 
%%% 
%%%%IMPORTANTE: ACTUALIZAR LOS DIRECTORIOS DE CARGA DE INFORMACION Y GUARDADO DE SALIDAS
%%%%COPIAR LOS ARCHIVOS .mat DE LAYOUT, COMPAÑIA RESULTADOS EN CARPETA DE PRUEBAS (TAMBIEN COPIAR ESTE ULTIMO EN LA CARPETA DE RESULTADOS)
%%%%ESTOS ARCHIVOS SE OBTIENEN INMEDIATAMENTE DESPÚES DE QUE EL EJECUTABLE TERMINA SU PROCESO DE VALIDACIÓN DE LOS TXT,
%%%%ANTES DE HACER LA CORRIDA COMPLETA DEL RCS...

%DEFINICION DE DIRECTORIOS DE INSUMOS Y SALIDAS
%dir='C:\Users\adan_\Documents\AdanFiles\Consultorias\Herramientas_RCS\ContribucionRCSActivos_Allianz\';%pruebasindividuales\';
dir=paramRCS.dir;
dirEntradas=[dir 'ParametrosEntrada\'];
dirSalidas=[dir 'ResultadosSalida\'];

contMargRCS=0;
warning('off');

%INICIALIZACION DE PARAMETROS GENERALES (CONFORME AL SCRIPT Calculos_ResyReq_app Y PROCEDIMIENTOS DE CADA MODELO)
global CIA archivo paramfile Parametros n t reprocesar
t=1;%Horizonte de riesgo
%n=100000;%Numero de escenarios (Verificar consistencia con el Conjunto de Prueba y con el de Resultados de Simulaciones)
%CIA.fechacorte=num2str(20170331);%Fecha del corte de información (aaaammdd)
%costoCapital=.15;
%inflacion=.05;
n=str2double(paramRCS.numEscenarios);%Numero de escenarios (Verificar consistencia con el Conjunto de Prueba y con el de Resultados de Simulaciones)
CIA.str='S0003';%Identificador compañia
CIA.fechacorte=paramRCS.fechacorte;%Fecha del corte de información (aaaammdd)
reprocesar=0;
complementos=0;
costoCapital=str2double(paramRCS.costoCapital);
inflacion=str2double(paramRCS.inflacion);
rF=.065;%Tasa libre de riesgo


%I. CALCULO DE RCS POR INSTRUMENTO INDIVIDUAL
Modificado_Inicializacion;%SCRIPT DE INICIALIZACION DE VARIABLES GENERALES
%Modificado_Proc_Reaseguro;%SCRIPT DE INICIALIZACION DE REASEGURO
if(~reprocesar)
    load ([dirEntradas 'RR4RSIM' CIA.str CIA.fechacorte '.mat']);%
    Modificado_EscenariosCap%SIMULACION ESCENARIOS CAPITALES (NECESARIO PUES EL ARCHIVO DE RESULTADOS "RR4RSIM") 
else
    Modificado_Proc_Activo_DeuyCap%SCRIPT MODIFICADO PARA REPLICA Y CALCULOS ADICIONALES
end
q=.995;%NIVEL DE CONFIANZA DE LAS METRICAS DE RIESGO


%a) CALCULO DESAGREGADO DE RCS PARA EL PORTAFOLIO DE DEUDA
LayoutDeu=Layoutglobal.Financiero.Layout; % Archivo de Layout
SeguroF=Layout.Deu.SeguroF;
indSeguroF=(SeguroF==0|SeguroF==2); % 0 general, 2 flexible con garatía de tasa
tipoValor=Layout.Deu.TipoDeValor(indSeguroF);tipoValor_Deu=tipoValor;
emisor=Layout.Deu.cadenaEmisor(indSeguroF);emisor_Deu=emisor;
serie=Layout.Deu.Serie(indSeguroF);serie_Deu=serie;
valorMercado=(Layout.Deu.Valor_Mercado(indSeguroF));valorMercado_Deu=valorMercado;
calificacion=Layout.Deu.calif(indSeguroF);%0='Gub',1='AAA',2='AA',3='A',4='BBB',5='BB',6='B',7='C'
curvaBono=Layout.Deu.curva_bono(indSeguroF);%1='BonosM',2='UMS',3='UDIBonos',4='TBills'
curvaCupon=Layout.Deu.curva_cpn(indSeguroF);%0=NoCuponado, 1=CETES, 2=PRLV, 3=LIBOR, 4=TIIE, 5=BREMS, 6=OTRA
tasaCupon=Layout.Deu.tasa_fija_cpn_col(indSeguroF);
monedaBase=Layout.Deu.moneda_base(indSeguroF);
nFin_Deu=length(emisor_Deu);
VaRDeu_Instr=zeros(nFin_Deu,1);
LDeu_Instr=repmat(valorMercado_Deu,1,n)-Resultados.Activo.Bonind1;%VARIABLE DE PERDIDA BONOS INDIVIDUALES (UTILIZA VARIABLES DE SALIDA REDONDEADAS HASTA 4 DECIMALES QUE HACE EL SCRCS) 
for i=1:nFin_Deu
    VaRDeu_Instr(i,:)=cuantil_ol(LDeu_Instr(i,:),q);
end
%%DESCOMPOSICION MARGINAL DEL RCS AGREGADO: RELATIVO A DEUDA
X=LDeu_Instr';
[VaR_kerNorm,VaR_kerTri,VaR_Ellip,VaR_Cov,VaR_Prop,VaR_DecPos_Deu,VaR]=Modificado_EulerAllocation(X,q);
VaRDeu_Tabla=table(tipoValor,emisor,serie,valorMercado_Deu,VaRDeu_Instr,VaR_kerNorm,VaR_DecPos_Deu,calificacion,curvaBono,curvaCupon,tasaCupon,monedaBase);
VaR_Instr=VaRDeu_Instr;
subPort=cellstr(repmat('Deuda',nFin_Deu,1));
VaRActivosTot_Tabla=table(subPort,tipoValor,emisor,serie,valorMercado,VaR_Instr);


%b) CALCULO DESAGREGADO DE RCS PARA EL PORTAFOLIO DE RENTA VARIABLE
SeguroF=Layout.Cap.SeguroF;
indSeguroF=(SeguroF==0|SeguroF==2);
tipoValor=Layout.Cap.TipoV(indSeguroF);
emisor=Layout.Cap.Emisor(indSeguroF);
serie=Layout.Cap.Serie(indSeguroF);
monedaBase=Layout.Cap.moneda_base(indSeguroF);
s0Acc=cell(Parametros.General.n_cap,1);%ARREGLO DEL VALOR DE MERCADO ACTUAL DE LAS ACCIONES ASOCIADAS A CADA INDICE BURSÁTIL SECTORIAL
wAcc=cell(Parametros.General.n_cap,1);%ARREGLO DE LA COMPOSICION DE LAS ACCIONES ASOCIADAS A CADA INDICE BURSÁTIL SECTORIAL
indiceSect=cell(Parametros.General.n_cap,1);%ARREGLO DE INDICES SECTORIALES QUE AGRUPAN A LAS ACCIONES (VARIABLE DE ORDENAMIENTO DE VaR INDIVIDUAL DE CADA ACCION) 
tipoCap=cell(Parametros.General.n_cap,1);%ARREGLO DEL TIPO DE CAPITAL DE LAS ACCIONES ASOCIADAS A CADA INDICE BURSATIL
                                         %1='AccD',2='AccF',3='Soc',4='TrD';5='TrF',6='SocPr',7='Estr',8='NE',9='NB',10='Inm'
VaRAcc=cell(Parametros.General.n_cap,1);%ARREGLO DEL VaR INDIVIDUAL DE CADA ACCION ASOCIADA POR INDICE SECTORIAL
LAcc=cell(Parametros.General.n_cap,1);%ARREGLO DE VARIABLES DE PERDIDA INDIVIDUALES DE CADA ACCION ASOCIADA POR INDICE SECTORIAL
LCap_Indice=zeros(size(Cap1desg));%ESCENARIOS DE PERDIDA AGREGADA POR CADA INDICE SECTORIAL
LCap_Tipo=zeros(length(clave_repCapUn),n);%ESCENARIOS DE PERDIDA AGREGADA POR TIPO DE CAPITAL
VaRCap_Indice=zeros(size(Cap1desg,1),1);%VECTOR DE VaR INDIVIDUAL DE CADA INDICE BURSÁTIL
VaRCap_Tipo=zeros(length(clave_repCapUn),1);
temp=0;
ordSector=zeros(sum(indSeguroF),1);
for j=1:2%CALCULO POR INDICE SECTORIAL: indCap_t EN idx 
    for i=1:n_ind(j)%VECTOR DEL NUMERO DE INDICES LOCALES (10) Y EXTRANJEROS (14)  
        indCap_t=(indCap==i).*(domCap==j);
        indCap_t=find(indCap_t==1);%INDICES DE LAS ACCIONES INDIVIDUALES CORRESPONDIENTES A CADA ÍNDICE BURSÁTILES 
        idx=(j-1)*Parametros.General.n_capd+i;%INDICES DEL RECORRIDO EN LOS ARREGLOS ASOCIADOS A LOS 24 INDICES BURSÁTILES SECTORIALES 
        if(isempty(indCap_t)==0)
            nInd=length(indCap_t);%NUMERO DE ACCIONES QUE ASOCIADAS AL INDICE idx 
            ordSector(temp+(1:nInd))=indCap_t;
            LCap_Indice(idx,:)=sum(montCap(indCap_t))-Cap1desg(idx,:);%ESCENARIOS DE LA VARIABLE DE PERDIDA ASOCIADA A CADA INDICE BURSÁTIL 
            VaRCap_Indice(idx)=cuantil_ol(LCap_Indice(idx,:),q);
            indiceSect{idx}=repmat(idx,nInd,1);
            tipoCap{idx}=clave_repCap(indCap_t);
            s0Acc{idx}=montCap(indCap_t);%ARREGLO DE VALOR DE MERCADO DE LAS ACCIONES ASOCIADAS A CADA INDICE BURSÁTIL 
            wAcc{idx}=s0Acc{idx}./sum(s0Acc{idx});%ARREGLO DE VECTOR DE PESOS RELATIVOS DE LAS ACCION ASOCIADAS A CADA INDICE BURSÁTIL 
            LAcc{idx}=repmat(LCap_Indice(idx,:),nInd,1).*repmat(wAcc{idx},1,n);%ESCENARIOS DE PERDIDA ASOCIADOS A CADA ACCION INDIVIDUAL (ORDENAMIENTO DE RENGLONES POR INDICES SECTORIALES) 
            VaRAcc{idx}=VaRCap_Indice(idx)*wAcc{idx};%OBSERVACION: VaRindCap(k)=sum(VaRAcc{k}), k=1,...,24 
            temp=temp+nInd;
        end
    end
end
for i=1:length(clave_repCapUn)%CALCULO POR TIPO DE CAPITAL: clave_repCap==clave_repCapUn(i)
    nombre=char(VecClave{clave_repCapUn(i)});
    LCap_Tipo(i,:)=Resultados.Activo.Cap.(nombre).A0-Resultados.Activo.Cap.(nombre).A1;
    VaRCap_Tipo(i)=cuantil_ol(LCap_Tipo(i,:),q);
end
VaRCap_Instr=cell2mat(VaRAcc);%VaR POR INSTRUMENTO (ACCION INDIVIDUAL ASOCIADA A CADA INDICE SECTORIAL: ORDENAMIENTO POR INDICE SECTORIAL)
LCap_Instr=cell2mat(LAcc);%ESCENARIOS DE PERDIDA POR INSTRUMENTO (ACCION INDIVIDUAL ASOCIADA A CADA INDICE SECTORIAL: ORDENAMIENTO POR INDICE SECTORIAL)
valorMercado=cell2mat(s0Acc);valorMercado_Cap=valorMercado;%VALOR DE MERCADO DE CADA ACCION INDIVIDUAL (ORDENAMIENTO POR INDICE SECTORIAL)
indiceSector=cell2mat(indiceSect);%SECTOR AL QUE ESTA ASOCIADA CADA ACCION INDIVIDUAL
tipoCapital=cellstr(char(VecClave{cell2mat(tipoCap)}));%TIPO DE CAPITAL DE CADA ACCION INDIVIDUAL 
tipoCapital_Un=cellstr(char(VecClave{clave_repCapUn}));%TIPO DE CAPITAL (UNICO) EXISTEN EN LA CARTERA DE RENTA VARIABLE 
tipoCapital_Num=cell2mat(tipoCap);%TIPO DE CAPITAL DE CADA ACCION BAJO TIPO NUMERICO
tipoValor=tipoValor(ordSector);tipoValor_Cap=tipoValor;
emisor=emisor(ordSector);emisor_Cap=emisor;
serie=serie(ordSector);serie_Cap=serie;
nFin_Cap=length(serie);
%%DESCOMPOSICION MARGINAL DEL RCS AGREGADO: RELATIVO A CAPITALES
X=LCap_Instr';
[VaR_kerNorm,VaR_kerTri,VaR_Ellip,VaR_Cov,VaR_Prop,VaR_DecPos_Cap,VaR]=Modificado_EulerAllocation(X,q);
VaRCap_Tabla=table(tipoValor,emisor,serie,valorMercado,VaRCap_Instr,VaR_kerNorm,VaR_DecPos_Cap,indiceSector,tipoCapital);

%c) CALCULO DESAGREGADO DE RCS PARA LOS IMPORTES RECUPERABLES DE REASEGURO DE MONTO CONOCIDO ('Irea') 
if isfield(Layoutglobal,'LAIRRea')
    LIrea_Instr=Resultados.Activo.Irea.A0-Resultados.Activo.Irea.A1;%CORRESPONDE A LAS PERDIDAS SOLO POR DEFAULT DE LA CONTRAPARTE (SIN RIESGO FINANCIERO) 
else
    LIrea_Instr=[];
end

%c.1) CALCULOS DE DESCOMPOSICION MARGINAL DEL RCS AGREGADO A NIVEL DE ACTIVO TOTAL (ALINEADO CON TXT DE CARGA) 
X=[LDeu_Instr',LCap_Instr',LIrea_Instr'];
[VaR_kerNorm,VaR_kerTri,VaR_Ellip,VaR_Cov,VaR_Prop,VaR_DecPos,VaR]=Modificado_EulerAllocation(X,q);
VaR_Instr=VaRCap_Instr;
subPort=cellstr(repmat('Capitales',nFin_Cap,1));
VaRActivosTot_Info=[VaRActivosTot_Tabla;table(subPort,tipoValor,emisor,serie,valorMercado,VaR_Instr)];
if isfield(Layoutglobal,'LAIRRea')
    VaRActivosTot_Info=[VaRActivosTot_Info;cell2table({'ImpRecRea','NA','IMPREC','NA',Resultados.Activo.Irea.A0,cuantil_ol(LIrea_Instr,q)},'VariableNames',{'subPort','tipoValor','emisor','serie','valorMercado','VaR_Instr'})];
end
VaRActivosTot_Tabla=[VaRActivosTot_Info,table(VaR_kerNorm,VaR_DecPos)];
%c.2) CALCULOS DE DESCOMPOSICION MARGINAL DEL RCS AGREGADO Y AGRUPADO A NIVEL DE ACTIVO TOTAL ÚNICO 
[C_Un,ia,ic]=unique(VaRActivosTot_Info(:,1:4));
valorMercado=accumarray(ic,VaRActivosTot_Info.valorMercado);%VALORES SUMARIZADOS POR INSTRUMENTO UNICO 
VaR_Instr=accumarray(ic,VaRActivosTot_Info.VaR_Instr);%VALORES SUMARIZADOS POR INSTRUMENTO UNICO 
[c,r]=meshgrid(ic,1:size(X,1));%CONSTRUCCION DE ARREGLO SOBRE LAS DIMENSIONES DE LOS ESCENARIOS DE PERDIDAS E INSTRUMENTOS 
X_Un=accumarray([c(:),r(:)],X(:))';%CONSOLIDACION DE PERDIDAS POR INSTRUMENTOS UNICOS!!!!!! 
[VaR_kerNorm,VaR_kerTri,VaR_Ellip,VaR_Cov,VaR_Prop,VaR_DecPos,VaR]=Modificado_EulerAllocation(X_Un,q);
VaRActivosTot_Tabla_Un=[C_Un,table(valorMercado,VaR_Instr,VaR_kerNorm,VaR_DecPos)];
%%%%IMPORTANTE: LOS RESULTADOS DE RCS MARGINAL COINCIDEN AGRUPADOS POR INSTRUMENTOS UNICOS Y COMO SE CARGA EN TXT EN VARIOS REGISTROS 

%d) CALCULO AGREGADO DE TODO EL PORTAFOLIO DE ACTIVOS (DEUDA Y CAPITALES) y SUBCATEGORIAS 
VaRActivos_Agregado=cuantil_ol(sum(LDeu_Instr,1)+sum(LCap_Indice,1),q);%VaR DEL PORTAFOLIO DE ACTIVOS TOTALES AGREGADO
VaRDeu_Agregado=cuantil_ol(sum(LDeu_Instr,1),q);%VaR DEL PORTAFOLIO DE DEUDA AGREGADO
VaRCap_Agregado=cuantil_ol(sum(LCap_Indice,1),q);%VaR DEL PORTAFOLIO DE CAPITALES AGREGADO
%VaR DEL PORTAFOLIO DE DEUDA POR GRUPO DE ACTIVOS
SeguroF=Layoutglobal.Financiero.Layout.Deu.SeguroF;%INDICADORA DE SEGURO FLEXIBLE PORTAFOLIO DEUDA 
indSeguroF=(SeguroF==0|SeguroF==2); % 0 general, 2 flexible con garatía de tasa
indGubLocal=(calificacion==0)&(Layoutglobal.Financiero.Layout.Deu.Emisor(indSeguroF)==1);
VaRDeu_GubLocal=cuantil_ol(sum(LDeu_Instr(indGubLocal,:),1),q);%VaR DEL PORTAFOLIO DE BONOS GUBERNAMENTALES LOCALES
VaRDeu_OtrosEmisores=cuantil_ol(sum(LDeu_Instr(~indGubLocal,:),1),q);%VaR DEL PORTAFOLIO DEL RESTO DE EMISORES (LOCALES Y EXTRANJEROS)
%VaR DEL PORTAFOLIO DE DEUDA ASOCIADO A CADA CURVA
curvaBono_Un=unique(curvaBono);
VaRDeu_Curva=zeros(length(curvaBono_Un),1);
for i=1:length(VaRDeu_Curva)
    VaRDeu_Curva(i)=cuantil_ol(sum(LDeu_Instr(curvaBono==curvaBono_Un(i),:),1),q);
end
%VaR DEL PORTAFOLIO DE DEUDA ASOCIADO A CADA CALIFICACION CREDITICIA
calificacion_Un=unique(calificacion);
VaRDeu_Calif=zeros(length(calificacion_Un),1);
for i=1:length(VaRDeu_Calif)
    VaRDeu_Calif(i)=cuantil_ol(sum(LDeu_Instr(calificacion==calificacion_Un(i),:),1),q);%VaR DEL PORTAFOLIO DE DEUDA LIGADO A LA CALIFICACION CORRESPONDIENTE
end
%VaR DEL PORTAFOLIO DE CAPITALES POR GRUPOS DE ACTIVOS
VaRCap_Acc=cuantil_ol(sum(LCap_Instr(tipoCapital_Num<=2,:),1),q);%VaR DEL PORTAFOLIO DE SOLO ACCIONES (TIPO CAPITAL 1 A 2: 'AccD','AccF')
VaRCap_RV=cuantil_ol(sum(LCap_Instr(tipoCapital_Num<=7,:),1),q);%VaR DEL PORTAFOLIO DE SOLO RENTA VARIABLE (TIPO CAPITAL 1 A 7: 'AccD','AccF','Soc','TrD','TrF','SocPr','Estr') AGREGADO
VaRCap_NE=cuantil_ol(sum(LCap_Instr(tipoCapital_Num==8,:),1),q);%VaR DEL PORTAFOLIO DE SOLO NOTAS ESTRUCTURADAS (TIPO CAPITAL 8: 'NE')
VaRCap_NB=cuantil_ol(sum(LCap_Instr(tipoCapital_Num==9,:),1),q);%VaR DEL PORTAFOLIO DE SOLO ACCIONES NO BURSÁTILES (TIPO CAPITAL 9: 'NB')
VaRCap_Inm=cuantil_ol(sum(LCap_Instr(tipoCapital_Num==10,:),1),q);%VaR DEL PORTAFOLIO DE SOLO INMUEBLES (TIPO CAPITAL 10: 'Inm')
%EFECTOS DE DIVERSIFICACION GLOBALES
efectoDiv_Deu=sum(VaRDeu_Instr)-VaRDeu_Agregado;%EFECTO DIVERSIFICACION DEUDA
efectoDiv_Cap=sum(VaRCap_Instr)-VaRCap_Agregado;%EFECTO DIVERSIFICACION CAPITALES
efectoDiv_Activos=sum(VaRDeu_Instr)+sum(VaRCap_Instr)-VaRActivos_Agregado;%EFECTO DIVERSIFICACION ACTIVOS TOTALES 

%e) GUARDADO DE VARIABLES PARA EFECTOS DE REPORTES EN ARCHIVOS CSV
cal={'Gub','AAA','AA','A','BBB','BB','B','C'}';
calif_Etiqueta=cal(1:length(calificacion_Un));
curva={'BonosM','UMS','UDIBonos','TBills'}';
curva_Etiqueta=curva(1:length(curvaBono_Un));
indiceSectorial=(1:24)';
writetable(VaRDeu_Tabla,[dirSalidas 'VaRDeu_InstrIndiv.csv'])
writetable(table(VaRDeu_GubLocal,VaRDeu_OtrosEmisores),[dirSalidas 'VaRDeu_SubPort.csv'])
writetable(table(calif_Etiqueta,VaRDeu_Calif),[dirSalidas 'VaRDeu_Calificacion.csv'])
writetable(table(curva_Etiqueta,VaRDeu_Curva),[dirSalidas 'VaRDeu_TipoCurva.csv'])
writetable(VaRCap_Tabla,[dirSalidas 'VaRCap_InstrIndiv.csv'])
writetable(table(VaRCap_Acc,VaRCap_RV,VaRCap_NE,VaRCap_NB,VaRCap_Inm),[dirSalidas 'VaRCap_SubPort.csv'])
writetable(table(tipoCapital_Un,VaRCap_Tipo),[dirSalidas 'VaRCap_TipoCapital.csv'])
writetable(table(indiceSectorial,VaRCap_Indice),[dirSalidas 'VaRCap_IndiceSectorial.csv'])
writetable(table(efectoDiv_Deu,efectoDiv_Cap,efectoDiv_Activos),[dirSalidas 'EfectosDiversificacion.csv'])
writetable(VaRActivosTot_Tabla,[dirSalidas 'VaRActivosTot_ContribMarginales.csv'])
writetable(VaRActivosTot_Tabla_Un,[dirSalidas 'VaRActivosTot_ContribMarginales_Un.csv'])
%TABLA DE RESULTADOS GLOBAL DE LOS ACTIVOS POR INSTRUMENTOS ÚNICOS (FILTRO: TIPOVALOR|EMISOR|SERIE) mas amigable que usar "accumarray(subs,val)", pero mismo resultado 
xActU=grpstats(VaRActivosTot_Tabla,{'subPort','tipoValor','emisor','serie'},'sum','DataVars',{'valorMercado','VaR_Instr','VaR_kerNorm','VaR_DecPos'});%AGRUPAMIENTO A INSTRUMENTOS UNICOS 
writetable(xActU,[dirSalidas 'VaRActivosTotU_ContribMarginales.csv'])
dlmwrite([dirSalidas 'LDeu_Instr.csv'],LDeu_Instr','precision',15)
dlmwrite([dirSalidas 'LCap_Instr.csv'],LCap_Instr','precision',15)
dlmwrite([dirSalidas 'LCap_Indice.csv'],LCap_Indice','precision',15)
dlmwrite([dirSalidas 'LCap_Tipo.csv'],LCap_Tipo','precision',15)
dlmwrite([dirSalidas 'LIrea_Instr.csv'],LIrea_Instr','precision',15)


%f) GRAFICAS DE RESULTADOS DE DESCOMPOSICION MARGINAL DEL RCS 
colRCSind=[.8,.8,.8];%GRIS CLARO
colRCSmar='m';%MAGENTA
tickInd=6;%TAMAÑO DE LOS TICKERS DE CADA INSTRUMENTO

figure(1)%RCS MARGINAL DEUDA
xx=xActU(logical(strcmp(xActU.subPort,'Deuda')+strcmp(xActU.subPort,'ImpRecRea')),{'tipoValor','emisor','serie','sum_valorMercado','sum_VaR_Instr','sum_VaR_DecPos'});%AGRUPAMIENTO A INSTRUMENTOS UNICOS 
[~,I]=sort(xx.sum_VaR_DecPos,'descend');%ORDENAMIENTO DE MAYOR A MENOR CONTRIBUCION DE RCS 
xEtiq=strcat(xx.emisor(I),'.',xx.serie(I));
xEtiq(strcmp(xEtiq,'IMPREC.NA'))=cellstr('IREASEGURO');
xTick=1:size(xx,1);
h=subplot(2,1,1); p=get(h,'pos'); p(2)=p(2)-0.05; p(4)=p(4)+0.10; set(h,'pos',p);%MANEJO DE LA BASE p(2) Y ALTO p(4) DE LA SUB-GRAFICA  
bar(100*xx.sum_VaR_Instr(I)./xx.sum_valorMercado(I),'FaceColor',colRCSind,'EdgeColor',colRCSind);hold on%GRAFICA DE VaR INDIVIDUAL DE CADA INSTRUMENTO (COMO PROPORCION DE SU VALOR DE MERCADO)
set(gca,'Xtick',xTick,'XTickLabel','','FontSize',5,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Xlim',[0,length(xTick)+1],'Ylim',[0,115*max(xx.sum_VaR_Instr(I)./xx.sum_valorMercado(I))]);
aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10;
ylabel('(% de su valor de mercado)','FontSize',10)
title('RCS por instrumento individual: Deuda','FontSize',12)
bar(100*xx.sum_VaR_DecPos(I)./xx.sum_valorMercado(I),.6,'FaceColor',colRCSmar,'EdgeColor',colRCSmar);hold off
legend('str',{'RCS individual (posiciones independientes)','Contribución marginal al RCS (Total Activos)'},'Location','northEast','FontSize',6);
legend boxoff
aux=gca;aux.YGrid='on';aux.GridLineStyle='-.';
subplot(2,1,2);hold on; p=get(h,'pos'); p(2)=p(2)-0.05; p(4)=p(4)+0.0; set(h,'pos',p);%MANEJO DE LA BASE p(2) Y ALTO p(4) DE LA SUB-GRAFICA  
bar(xx.sum_VaR_DecPos(I)/10^6,'FaceColor','m','EdgeColor','m');hold off
set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Xlim',[0,length(xTick)+1]);
aux=gca; aux.YAxisLocation='right'; aux.YAxis.FontSize=10;
ylabel('(Millones de MXN)','FontSize',10)
aux=gca;aux.XGrid='on';aux.YGrid='on';aux.GridLineStyle='-.';
fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f1',[dirSalidas 'Fig1' '.png'],'-dpng','-r0')

figure(2)%RCS MARGINAL CAPITALES
xx=xActU(strcmp(xActU.subPort,'Capitales'),{'tipoValor','emisor','serie','sum_valorMercado','sum_VaR_Instr','sum_VaR_DecPos'});%AGRUPAMIENTO A INSTRUMENTOS UNICOS 
[~,I]=sort(xx.sum_VaR_DecPos,'descend');%ORDENAMIENTO DE MAYOR A MENOR CONTRIBUCION DE RCS 
xEtiq=strcat(xx.emisor(I),'.',xx.serie(I));
xEtiq(strcmp(xEtiq,'INMOB.1'))=cellstr('INMUEBLES');
xTick=1:size(xx,1);
h=subplot(2,1,1); p=get(h,'pos'); p(2)=p(2)-0.05; p(4)=p(4)+0.10; set(h,'pos',p);%MANEJO DE LA BASE p(2) Y ALTO p(4) DE LA SUB-GRAFICA  
bar(100*xx.sum_VaR_Instr(I)./xx.sum_valorMercado(I),'FaceColor',colRCSind,'EdgeColor',colRCSind);hold on%GRAFICA DE VaR INDIVIDUAL DE CADA INSTRUMENTO (COMO PROPORCION DE SU VALOR DE MERCADO)
set(gca,'Xtick',xTick,'XTickLabel','','FontSize',5,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Xlim',[0,length(xTick)+1],'Ylim',[0,115*max(xx.sum_VaR_Instr(I)./xx.sum_valorMercado(I))]);
aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10;
ylabel('(% de su valor de mercado)','FontSize',10)
title('RCS por instrumento individual: Capitales','FontSize',12)
bar(100*xx.sum_VaR_DecPos(I)./xx.sum_valorMercado(I),.6,'FaceColor',colRCSmar,'EdgeColor',colRCSmar);hold off
legend('str',{'RCS individual (posiciones independientes)','Contribución marginal al RCS (Total Activos)'},'Location','northEast','FontSize',6);
legend boxoff
aux=gca;aux.YGrid='on';aux.GridLineStyle='-.';
subplot(2,1,2);hold on; p=get(h,'pos'); p(2)=p(2)-0.05; p(4)=p(4)+0.0; set(h,'pos',p);%MANEJO DE LA BASE p(2) Y ALTO p(4) DE LA SUB-GRAFICA  
bar(xx.sum_VaR_DecPos(I)/10^6,'FaceColor','m','EdgeColor','m');hold off
set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Xlim',[0,length(xTick)+1]);
aux=gca; aux.YAxisLocation='right'; aux.YAxis.FontSize=10;
ylabel('(Millones de MXN)','FontSize',10)
aux=gca;aux.XGrid='on';aux.YGrid='on';aux.GridLineStyle='-.';
fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f2',[dirSalidas 'Fig2' '.png'],'-dpng','-r0')




if complementos==1%SI SE ELIGEN ANALISIS ADICIONALES AL RCS MARGINAL
    
    %g) ANALISIS DE APROXIMACION DE RCS MEDIANTE EL USO DE METRICAS DE RIESGO INDIVIDUALES, VOLATILIDADES Y CORRELACIONES IMPLICITAS
    corrDeu=corr(LDeu_Instr');%MATRIZ DE CORRELACIONES VARIABLES DE PERDIDA INDIVIDUALES INSTRUMENTOS DE DEUDA
    corrDeu_GubLocal=corr(LDeu_Instr(indGubLocal,:)');
    corrDeu_OtrosEmisores=corr(LDeu_Instr(~indGubLocal,:)');
    idxCap2=tipoCapital_Num<=2;
    idxCap7=tipoCapital_Num<=7;
    idxCap9=tipoCapital_Num==9;
    idxCap10=tipoCapital_Num==10;
    if sum(idxCap2)>0
        corrCap_Acc=corr(LCap_Instr(idxCap2,:)');
    else
        corrCap_Acc=0;
    end
    if sum(idxCap7)>0
        corrCap_RV=corr(LCap_Instr(idxCap7,:)');
    else
        corrCap_RV=0;
    end
    if sum(idxCap9)>0
        corrCap_NB=corr(LCap_Instr(idxCap9,:)');
    else
        corrCap_NB=0;
    end
    if sum(idxCap10)>0
        corrCap_Inm=corr(LCap_Instr(idxCap10,:)');
    else
        corrCap_Inm=0;
    end
    corrCap=corr(LCap_Instr');%MATRIZ DE CORRELACIONES VARIABLES DE PERDIDA INDIVIDUALES INSTRUMENTOS DE CAPITALES
    corrActivos=corr([LDeu_Instr',LCap_Instr']);%MATRIZ DE CORRELACIONES VARIABLES DE PERDIDA INDIVIDUALES INSTRUMENTOS TOTAL ACTIVOS
    VaRDeu_Corr=(VaRDeu_Instr'*corrDeu*VaRDeu_Instr)^.5;
    VaRDeu_GubLocal_Corr=(VaRDeu_Instr(indGubLocal)'*corrDeu_GubLocal*VaRDeu_Instr(indGubLocal))^.5;
    VaRDeu_OtrosEmisores_Corr=(VaRDeu_Instr(~indGubLocal)'*corrDeu_OtrosEmisores*VaRDeu_Instr(~indGubLocal))^.5;
    VaRCap_Acc_Corr=(VaRCap_Instr(idxCap2)'*corrCap_Acc*VaRCap_Instr(idxCap2))^.5;
    VaRCap_RV_Corr=(VaRCap_Instr(idxCap7)'*corrCap_RV*VaRCap_Instr(idxCap7))^.5;
    VaRCap_NB_Corr=(VaRCap_Instr(idxCap9)'*corrCap_NB*VaRCap_Instr(idxCap9))^.5;
    VaRCap_Inm_Corr=(VaRCap_Instr(idxCap10)'*corrCap_Inm*VaRCap_Instr(idxCap10))^.5;
    VaRCap_Corr=(VaRCap_Instr'*corrCap*VaRCap_Instr)^.5;
    VaRActivos_Corr=([VaRDeu_Instr',VaRCap_Instr']*corrActivos*[VaRDeu_Instr;VaRCap_Instr])^.5;
    VaRDeu_Corr0=(VaRDeu_Instr'*eye(size(corrDeu))*VaRDeu_Instr)^.5;
    VaRDeu_GubLocal_Corr0=(VaRDeu_Instr(indGubLocal)'*eye(size(corrDeu_GubLocal))*VaRDeu_Instr(indGubLocal))^.5;
    VaRDeu_OtrosEmisores_Corr0=(VaRDeu_Instr(~indGubLocal)'*eye(size(corrDeu_OtrosEmisores))*VaRDeu_Instr(~indGubLocal))^.5;
    VaRCap_Acc_Corr0=(VaRCap_Instr(idxCap2)'*eye(size(corrCap_Acc))*VaRCap_Instr(idxCap2))^.5;
    VaRCap_RV_Corr0=(VaRCap_Instr(idxCap7)'*eye(size(corrCap_RV))*VaRCap_Instr(idxCap7))^.5;
    VaRCap_NB_Corr0=(VaRCap_Instr(idxCap9)'*eye(size(corrCap_NB))*VaRCap_Instr(idxCap9))^.5;
    VaRCap_Inm_Corr0=(VaRCap_Instr(idxCap10)'*eye(size(corrCap_Inm))*VaRCap_Instr(idxCap10))^.5;
    VaRCap_Corr0=(VaRCap_Instr'*eye(size(corrCap))*VaRCap_Instr)^.5;
    VaRActivos_Corr0=([VaRDeu_Instr',VaRCap_Instr']*eye(size(corrActivos))*[VaRDeu_Instr;VaRCap_Instr])^.5;
    VaR_Real=[VaRDeu_GubLocal,VaRDeu_OtrosEmisores,VaRDeu_Agregado,VaRCap_Acc,VaRCap_RV,VaRCap_NB,VaRCap_Inm,VaRCap_Agregado,VaRActivos_Agregado];
    VaR_Corr=[VaRDeu_GubLocal_Corr,VaRDeu_OtrosEmisores_Corr,VaRDeu_Corr,VaRCap_Acc_Corr,VaRCap_RV_Corr,VaRCap_NB_Corr,VaRCap_Inm_Corr,VaRCap_Corr,VaRActivos_Corr];
    VaR_Corr0=[VaRDeu_GubLocal_Corr0,VaRDeu_OtrosEmisores_Corr0,VaRDeu_Corr0,VaRCap_Acc_Corr0,VaRCap_RV_Corr0,VaRCap_NB_Corr0,VaRCap_Inm_Corr0,VaRCap_Corr0,VaRActivos_Corr0];
    figure(3)
    bar([VaR_Real',VaR_Corr',VaR_Corr0']./10^6)
    legend('RCS real (ejecutable)','Aproximación RCS bajo correlaciones implícitas','Aproximación RCS bajo correlaciones cero','Location','NorthWest','FontSize',10);
    legend boxoff
    set(gca,'XTickLabel',{'Deuda Gub Local','Deuda Otros Emisores','Total Deuda','Solo Acciones','Solo Renta Variable','No Bursátiles','Inmuebles','Total Capitales','Total Activos'},'FontSize',6);
    title('Efecto de agregación de RCS individuales por grupos de activos: aproximación bajo correlaciones lineales','FontSize',10)
    ylabel('(Millones de MXN)','FontSize',10)
    aux=gca; aux.YAxis.FontSize=10; grid(); aux.GridLineStyle='-.';
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f3',[dirSalidas 'Fig3' '.png'],'-dpng','-r0')
    writetable(table(VaRDeu_Corr0,VaRCap_Corr0,VaRActivos_Corr0,VaRDeu_Corr,VaRCap_Corr,VaRActivos_Corr,VaRDeu_Agregado,VaRCap_Agregado,VaRActivos_Agregado),[dirSalidas 'VaR_RealvsAproxCorrelaciones.csv'])
    dlmwrite([dirSalidas 'corrDeu.csv'],corrDeu,'precision',15)
    dlmwrite([dirSalidas 'corrCap.csv'],corrCap,'precision',15)
    dlmwrite([dirSalidas 'corrActivos.csv'],corrActivos,'precision',15)

    
    %h) ANALISIS DE RENTABILIDAD AJUSTADA POR RIESGO

    %DEUDA: USO DE YIELD REPORTADA EN EL VECTOR DE PRECIOS VALMER
    xx=xActU(strcmp(xActU.subPort,'Deuda'),{'tipoValor','emisor','serie','sum_valorMercado','sum_VaR_Instr','sum_VaR_DecPos'});%AGRUPAMIENTO A INSTRUMENTOS UNICOS
    [~,I]=sort(xx.sum_VaR_DecPos,'descend');%ORDENAMIENTO DE MAYOR A MENOR CONTRIBUCION DE RCS
    xEtiq=strcat(xx.emisor(I),'.',xx.serie(I));
    xTick=1:size(xx,1);
    tipoValor_Deu=xx.tipoValor(I);emisor_Deu=xx.emisor(I);serie_Deu=xx.serie(I);valorMercado_Deu=xx.sum_valorMercado(I);contribRCS_Deu=xx.sum_VaR_DecPos(I);
    [num,txt,raw]=xlsread( [dirEntradas 'vectorPiP_' CIA.fechacorte '.xls']);
    id_Vector=strcat(txt(:,2),txt(:,3),txt(:,4));
    id_Deu=strcat(tipoValor_Deu,emisor_Deu,serie_Deu);
    tvemi_Vector=strcat(txt(:,2),txt(:,3));
    tvemi_Deu=strcat(tipoValor_Deu,emisor_Deu);
    posVector=1:length(tvemi_Vector);
    ytmMedia=zeros(length(tvemi_Deu),1);
    ytm=ytmMedia;
    for i=1:length(tvemi_Deu)
        aux=posVector(strcmp(id_Vector,id_Deu(i)));
        if isempty(aux)
            ytm(i)=mean(cell2mat(raw(posVector(strcmp(tvemi_Vector,tvemi_Deu(i))),59)))/100;
        else
            ytm(i)=cell2mat(raw(aux,59))/100;
        end
        if strfind(char(serie_Deu(i)),'U')
            ytm(i)=ytm(i)+inflacion;%SE AGREGA LA INFLACION A LOS INSTRUMENTOS UDIZADOS (SERIE QUE CONTIENE "U")
        end
    end
    writetable(table(tipoValor_Deu,emisor_Deu,serie_Deu,valorMercado_Deu,contribRCS_Deu,ytm),[dirSalidas 'contribRCSvsYield_Deuda.csv'])
    RORAC=ytm./(contribRCS_Deu./valorMercado_Deu);%RENDIMIENTO (YIELD) AJUSTADO POR UNIDAD DE CONTRIBUCION DE RCS
    rendExcRCS=ytm-contribRCS_Deu./valorMercado_Deu;%RENDIMIENTO (YIELD) EN EXCESO A LA CONTRIBUCION DE RCS
    EVA=ytm-costoCapital*contribRCS_Deu./valorMercado_Deu;%VALOR ECONOMICO AÑADIDO (YIELD EN EXCESO AL COSTO NETO DEL RCS)
    
    figure(4)
    h=subplot(2,1,1); p=get(h,'pos'); p(2)=p(2)+0.05; p(4)=p(4)-0.10; set(h,'pos',p);escala=10^3;
    bar(100*RORAC/escala);hold on;
    set(gca,'Xtick',xTick,'XTickLabel','','FontSize',4,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Xlim',[0,length(xTick)+1]);
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10;
    title('Rendimiento (YTM) por unidad de contribución marginal al RCS: Instrumentos Deuda','FontSize',10)
    plot(repmat(10*costoCapital/escala,length(xTick)),'r','LineWidth',2)
    legend('str',{'Rendimiento ajustado por riesgo (RORAC)','Costo de capital (15%)'},'Location','best','FontSize',8);
    legend boxoff
    ylabel('(Por mil)','FontSize',10);hold off
    h=subplot(2,1,2);hold on; p=get(h,'pos'); p(2)=p(2)+0.10; p(4)=p(4)+0.05; set(h,'pos',p);hold on;%MANEJO DE LA BASE p(2) Y ALTO p(4) DE LA SUB-GRAFICA
    bar(100*RORAC);hold on;
    set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Ylim',[0,100],'Xlim',[0,length(xTick)+1]);
    plot(repmat(15,length(xTick)),'r','LineWidth',2)
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxisLocation='right'; aux.YAxis.FontSize=10;
    ylabel('Acercamiento (Zoom)','FontSize',10)
    hold off;
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f4',[dirSalidas 'Fig4' '.png'],'-dpng','-r0')
    
    figure(5)
    bar(xTick(rendExcRCS>=0),100*rendExcRCS(rendExcRCS>=0));hold on;
    bar(xTick(rendExcRCS<0),100*rendExcRCS(rendExcRCS<0),'r','EdgeColor','r');
    set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Xlim',[0,length(xTick)+1],'Ylim',100*[min(1.05*min(rendExcRCS),0),1.3*max(rendExcRCS)]);
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10; grid();aux.GridLineStyle='-.';
    title('Rendimiento (YTM) en exceso a la contribución marginal al RCS: Instrumentos Deuda','FontSize',10)
    hold off;
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f5',[dirSalidas 'Fig5' '.png'],'-dpng','-r0')
    
    figure(6)
    bar(xTick(EVA>=0),100*EVA(EVA>=0));hold on;
    %bar(x(EVA<0),100*EVA(EVA<0),.2,'FaceColor','r','EdgeColor','r');
    bar(xTick(EVA<0),100*EVA(EVA<0),'FaceColor','r','EdgeColor','r');
    set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Xlim',[0,length(xTick)+1],'Ylim',100*[min(1.05*min(EVA),0),1.3*max(EVA)]);
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10; grid();aux.GridLineStyle='-.';
    title('Rendimiento (YTM) en exceso al costo neto de la contribución marginal al RCS: Instrumentos Deuda','FontSize',10)
    legend('str',{'Valor económico añadido (EVA)'},'Location','best','FontSize',8);
    legend boxoff
    hold off;
    aux=gca;aux.YGrid='on';aux.GridLineStyle='-.';
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f6',[dirSalidas 'Fig6' '.png'],'-dpng','-r0')
    
    
    %CAPITALES: USO DEL PROMEDIO DE LOS ULTIMOS 12 RENDIMIENTOS MENSUALES COMO RENDIMIENTO ESPERADO (ANUALIZADO)
    xx=xActU(strcmp(xActU.subPort,'Capitales'),{'tipoValor','emisor','serie','sum_valorMercado','sum_VaR_Instr','sum_VaR_DecPos'});%AGRUPAMIENTO A INSTRUMENTOS UNICOS
    [~,I]=sort(xx.sum_VaR_DecPos,'descend');%ORDENAMIENTO DE MAYOR A MENOR CONTRIBUCION DE RCS
    xEtiq=strcat(xx.emisor(I),'.',xx.serie(I));
    xTick=1:size(xx,1);
    tipoValor_Cap=xx.tipoValor(I);emisor_Cap=xx.emisor(I);serie_Cap=xx.serie(I);valorMercado_Cap=xx.sum_valorMercado(I);contribRCS_Cap=xx.sum_VaR_DecPos(I);
    rendAnual_Cap=zeros(length(emisor_Cap),1);
    ticker=strcat(emisor_Cap,serie_Cap);
    rMax=rF;%TASA DE RENDIMIENTO ESPERADO MAXIMA IGUAL A LA TASA LIBRE DE RIESGO
    for i=1:length(emisor_Cap)
        if strcmp(serie_Cap(i),'NA')||strcmp(serie_Cap(i),'*')
            ticker=strcat(emisor_Cap(i),'.MX');
        elseif logical(strcmp(tipoCapital(i),'AccF')+strcmp(tipoCapital(i),'TrF'))
            ticker=strcat(emisor_Cap(i));
        else
            ticker=strcat(emisor_Cap(i),serie_Cap(i),'.MX');
        end
        try
            data=fetch(yahoo,ticker,'Adj Close',now-360,now,'m');
            data=sortrows(data,1);%ORDENAMIENTO EN ORDEN ASCENDENTE POR FECHA (PRIMERA COLUMNA)
            rendAnual_Cap(i)=12*mean(diff(log(data(:,2))));%RENDIMIENTO MEDIO OBSERVADO
            rendAnual_Cap(i)=min(rMax,max(rF,rendAnual_Cap(i)));%SE CONDICIONA A RENDIMIENTOS ESPERADOS MAYORES O IGUALES A LA LIBRE DE RIESGO DE 5% Y UN MAXIMO DE 50%
        catch
            rendAnual_Cap(i)=rF;%SI NO ENCUENTRA LA INFORMACION EN YAHOO FINANCE USA LA LIBRE DE RIESGO ('NB', 'Estr', ENTRE OTROS)
        end
    end
    %BUSQUEDA DE ACTIVOS EN EL VECTOR DE PRECIOS
    id_Vector=strcat(txt(:,2),txt(:,3),txt(:,4));
    id_Cap=strcat(tipoValor_Cap,emisor_Cap,serie_Cap);
    tvemi_Cap=strcat(tipoValor_Cap,emisor_Cap);
    ytmMedia=zeros(length(tvemi_Cap),1);
    ytm=ytmMedia;
    for i=1:length(tvemi_Cap)
        aux=posVector(strcmp(id_Vector,id_Cap(i)));
        if isempty(aux)
            ytm(i)=mean(cell2mat(raw(posVector(strcmp(tvemi_Vector,tvemi_Cap(i))),59)))/100;
        else
            ytm(i)=cell2mat(raw(aux,59))/100;
        end
        if strfind(char(serie_Cap(i)),'U')
            ytm(i)=ytm(i)+inflacion;%SE AGREGA LA INFLACION A LOS INSTRUMENTOS UDIZADOS (SERIE QUE CONTIENE "U")
        end
    end
    rendAnual_Cap(ytm>0)=ytm(ytm>0);%EN CASO DE ENCONTRAR TASA POSITIVA EN EL VECTOR DE PRECIOS SE UTILIZA EN VEZ DE YAHOO
    writetable(table(tipoValor_Cap,emisor_Cap,serie_Cap,valorMercado_Cap,contribRCS_Cap,rendAnual_Cap),[dirSalidas 'contribRCSvsYield_Cap.csv'])
    RORAC=rendAnual_Cap./(contribRCS_Cap./valorMercado_Cap);%RENDIMIENTO (YIELD) AJUSTADO POR UNIDAD DE CONTRIBUCION DE RCS
    rendExcRCS=rendAnual_Cap-contribRCS_Cap./valorMercado_Cap;%RENDIMIENTO (YIELD) EN EXCESO A LA CONTRIBUCION DE RCS
    EVA=rendAnual_Cap-costoCapital*contribRCS_Cap./valorMercado_Cap;%VALOR ECONOMICO AÑADIDO (YIELD EN EXCESO AL COSTO NETO DEL RCS)
    
    figure(7)
    h=subplot(2,1,1); p=get(h,'pos'); p(2)=p(2)+0.05; p(4)=p(4)-0.10; set(h,'pos',p);escala=10^3;
    bar(100*RORAC/escala);hold on;
    set(gca,'Xtick',xTick,'XTickLabel','','FontSize',4,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Xlim',[0,length(xTick)+1]);
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10;
    title('Rendimiento (YTM) por unidad de contribución marginal al RCS: Instrumentos Capitales','FontSize',10)
    plot(repmat(10*costoCapital/escala,length(xTick)),'r','LineWidth',2)
    legend('str',{'Rendimiento ajustado por riesgo (RORAC)','Costo de capital (15%)'},'Location','best','FontSize',8);
    legend boxoff
    ylabel('(Por mil)','FontSize',10);hold off
    h=subplot(2,1,2);hold on; p=get(h,'pos'); p(2)=p(2)+0.10; p(4)=p(4)+0.05; set(h,'pos',p);hold on;%MANEJO DE LA BASE p(2) Y ALTO p(4) DE LA SUB-GRAFICA
    bar(100*RORAC);hold on;
    set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Box','on','Ylim',[0,100],'Xlim',[0,length(xTick)+1]);
    plot(repmat(15,length(xTick)),'r','LineWidth',2)
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxisLocation='right'; aux.YAxis.FontSize=10;
    ylabel('Acercamiento (Zoom)','FontSize',10)
    hold off;
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f7',[dirSalidas 'Fig7' '.png'],'-dpng','-r0')
    
    figure(8)
    bar(xTick(rendExcRCS>=0),100*rendExcRCS(rendExcRCS>=0));hold on;
    bar(xTick(rendExcRCS<0),100*rendExcRCS(rendExcRCS<0),'r','EdgeColor','r');
    set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Xlim',[0,length(xTick)+1],'Ylim',100*[min(1.05*min(rendExcRCS),0),1.3*max(rendExcRCS)]);
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10; grid();aux.GridLineStyle='-.';
    title('Rendimiento (YTM) en exceso a la contribución marginal al RCS: Instrumentos Capitales','FontSize',10)
    hold off;
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f8',[dirSalidas 'Fig8' '.png'],'-dpng','-r0')
    
    figure(9)
    bar(xTick(EVA>=0),100*EVA(EVA>=0));hold on;
    %bar(x(EVA<0),100*EVA(EVA<0),.2,'FaceColor','r','EdgeColor','r');
    bar(xTick(EVA<0),100*EVA(EVA<0),.2,'FaceColor','r','EdgeColor','r');
    set(gca,'Xtick',xTick,'XTickLabel',xEtiq,'FontSize',tickInd,'XTickLabelRotation',90,'TickLength',[0,0],'Xlim',[0,length(xTick)+1],'Ylim',100*[min(1.05*min(EVA),0),1.3*max(EVA)]);
    aux=gca; aux.YAxis.TickLabelFormat='%g%%'; aux.YAxis.FontSize=10; grid();aux.GridLineStyle='-.';
    title('Rendimiento (YTM) en exceso al costo neto de la contribución marginal al RCS: Instrumentos Capitales','FontSize',10)
    legend('str',{'Valor económico añadido (EVA)'},'Location','best','FontSize',8);
    legend boxoff
    hold off;
    aux=gca;aux.YGrid='on';aux.GridLineStyle='-.';
    fig=gcf;fig.PaperPosition=[0 0 10 5];print('-f9',[dirSalidas 'Fig9' '.png'],'-dpng','-r0')
end
contMargRCS=dirSalidas; 
end
