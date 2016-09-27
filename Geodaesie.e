comment
Sammlung grundlegender Funktionen für Vermessung & Geodäsie
endcomment

ro = 200/pi();
R  = 6378.8;
a  = 6377397.155;
EE = 0.081696831215255838;
EE2= 0.006674372230614;
fi0= 0.81947406867612183;
l0 = 0.12984522414316146;
R=a*sqrt(1-EE2)/(1-EE2*sin(fi0)^2);
Alfa=sqrt(1+EE2/(1-EE2)*cos(fi0)^4);
b0=asin(sin(fi0)/Alfa);
K=log(tan(pi()/4+b0/2))-Alfa*log(tan(pi()/4+fi0/2))+Alfa*EE/2*log((1+EE*sin(fi0))/(1-EE*sin(fi0)));


function datan(x)
## gibt den Winkel in Gon zurück
return 200/pi()*atan(x)
endfunction

function datan2(y, x)
## gibt das Azimut in Gon im richtigen Quadranten
## bezueglich des Einheitskreises zurück 
a = datan(y / x);
if x < 0; 
a = a + 200; 
endif;
if y < 0 && x > 0;
a = a + 400;
endif;
return a;
endfunction

function Meteokorrektur(t,p)
##bringt meteorologisch bedingte Korrekturen an der Distanz an
##t=Temperatur[°Celsius]; p=Druck [mbar]
##und gibt Wert in ppm aus, (muss noch mit Distanz multipliziert werden!)
return (282-0.29*p/(1+0.0037*t))
endfunction

function DistRed(Ds,beta,i=0,s=0)
##reduziert Rohmessungen in Horizontaldistanzen und Höhendifferenz
##Ds: Schrägdistanz [m], beta: Höhenwinkel [Gon], I,S: Instr- resp. Zielhöhe
global ro
beta=beta+43.4e-7*Ds*cos(beta/ro);
dh=Ds*sin(beta/ro)+(i-s);
d=Ds*cos(beta/ro);
return {d,dh}
endfunction

function geomDistRed(X,H)
##reduziert meteorologisch korrigierte Horizontaldistanzen ins Projektionssystem
##und gibt Wert in ppm aus, (muss mit Distanz multipliziert werden!)
##X: Nordwert von Bern [km], H: H.ü.M [m]
global R;
return (X^2/2/R^2-H/R/1000)*1e6
endfunction

function YXLaFi(y,x)
## berechnet aus Landeskoordinaten geografische Länge und Breite
## sowie Meridiankonvergenz und Längenverzerrung, Resultate in dezimalen Altgrad
 global EE,a,EE2,fi0,l0;
 Y=y-600000; X=x-200000;
 l1=Y/R;
 b1=2*(atan(exp(X/R))-pi()/4);
 b=asin(cos(b0)*sin(b1)+sin(b0)*cos(b1)*cos(l1));
 l=atan(sin(l1)/(cos(b0)*cos(l1)-sin(b0)*tan(b1)));
 Lambda=l0+l/Alfa;
 fi=b;
  repeat S=1/Alfa*(log(tan(pi()/4+b/2))-K)+EE*log(tan(pi()/4+asin(EE*sin(fi))/2));
   finew=2*atan(exp(S))-pi()/2;
   if fi~=finew; break; endif;
   fi=finew;
  end;
 mu=atan((sin(b0)*sin(l))/(cos(b0)*cos(b)+sin(b0)*sin(b)*cos(l)));
 Rn=a/sqrt(1-EE2*sin(fi)^2);
 lv=Alfa*R/Rn*cos(b)/(cos(fi)*cos(b1));
 return {deg(Lambda),deg(fi),deg(mu),lv}
endfunction

function LaFiYX(Lambda,fi)
##berechnet aus geografischen Koordinaten [dez. Altgrad] Landeskoordinaten
 global a, EE, EE2, fi0, l0;
 Lambda=rad(Lambda); fi=rad(fi);
 S=Alfa*log(tan(pi()/4+fi/2))-Alfa*EE/2*log((1+EE*sin(fi))/(1-EE*sin(fi)))+K;
 b=2*(atan(exp(S))-pi()/4);
 l=Alfa*(Lambda-l0);
 l1=atan(sin(l)/(sin(b0)*tan(b)+cos(b0)*cos(l)));
 b1=asin(cos(b0)*sin(b)-sin(b0)*cos(b)*cos(l));
 Y=R*l1;
 X=R/2*log((1+sin(b1))/(1-sin(b1)));
 return {Y+600000, X+200000}
endfunction

function HorAeq(phi=47.522582°,A,h=0°)
##berechnet aus horizontalen Koordinaten (geogr. Breite, Azimut, Höhenwinkel [rad])
##aequatoriale Koordinaten (Stundenwinkel und Deklination  [rad])
$x=cos(phi)*sin(h)+sin(phi)*cos(h)*cos(A);
$y=cos(h)*sin(A);
$z=sin(phi)*sin(h)-cos(phi)*cos(h)*cos(A);
${t,dekli,r}=polar(x,y,z);
$return [t,dekli];
$endfunction

function AeqHor(phi=47.522582°,t,delta=23.44°)
##berechnet aus aequatorialen Koordinaten (geogr. Breite, Stundenwinkel, Deklination [rad])
##horizontale Koordinaten (Azimut und Höhenwinkel [rad])
$x=-cos(phi)*sin(delta)+sin(phi)*cos(delta)*cos(t);
$y=cos(delta)*sin(t);
$z=sin(phi)*sin(delta)+cos(phi)*cos(delta)*cos(t);
${A,h,r}= polar(x,y,z);
$return [A,h];
$endfunction

function MagDek(t,y,x)
##berechnet die magnetische Deklination in der Schweiz
## t: Jahr, y: Ostwert von Bern [m], x: Nordwert von Bern [m]
## Resultat in dezimalen Altgrad
t=t-1994.5; x=x*1e-3-200; y=y*1e-3-600;
f=(t+0.1614025e-02*t^2)/(1+0.6266612e-02*t);
return -0.7897745+0.5111305e-3*x+0.4072282e-02*y+(0.1222910*(1-.7800635e-3*x-.3524696e-3*y)*f)
endfunction

function Gewichtsmatrix(a,b)
##berechnet die Gewichtsmatrix für die Distanz-Eichstrecke in Aarau
##Eingabe (a=[mm], b=[ppm]
global n
p=10*[3,10,18,30,47,52,7,15,27,44,49,8,20,37,42];
p=b*p/1000; p=1/(p+a)^2;
P=id(n); P=setdiag(P,0,p);
return P
endfunction

function Schwend(A,l,a,b)
##Berechnung von Additionskonstante und Pfeiler (Kern-Areal) nach Schwendener
##A: Steuermatrix, l: Auswahl von Beobachtungen
##a,b: mF a priori einer Distanz (a [mm] + b [ppm])
##Ausgabe {x,Qxx,v,s02}
global n, u;
P=Gewichtsmatrix(a,b);
AP=A'.P; APA=AP.A;
Qxx=inv(APA);
x=xlgs(APA,AP.l');
v=A.x-l';
s02=diag(v'.P.v,0)/(n-u);
return {x,Qxx,v,s02};
endfunction

function LinRegr(M,x,y)
##lineare Regression nach der Methode der kleinsten Fehlerquadrate
##A: Übergabe Matrix, x: Spalten-Nr unabhängige Variable, y: Spalten-Nr abhängige Variable
##Resultat liefert [2,1]-Vektor, also Y-Achsenabschnitt(a) und Steigung (b) aus y=a+bx
A=M'; n=cols(A);
X=sum(A[x]);
X2=A[x].A[x]';
XY=A[x].A[y]';
Y=sum(A[y]);
b=Y_XY;
B=n|X; B=B_(X|X2);
L=B\b;
return L
endfunction

function LinRegr2(s)
##lineare Regression nach der Methode der kleinsten Fehlerquadrate
##s: Spaltenauswahl aus der Beobachtungsgruppe
global n, Messungen, Soll
x=sum(Messungen[s]);
x2=Messungen[s].Messungen[s]';
xy=Messungen[s].Soll;
y=ones(1,n).Soll;
b=y_xy;
B=n|x; B=B_(x|x2);
x=B\b;
x[2]=(x[2]-1)*1000; x=x*1000;
return x
endfunction
