// Formeln und Konstanten für L+K

// Ordnung der Indizes: I, A, K, bzw. ST, SK, BS, AS, PR, LR

Off:= [8,43,66,23,17,36;6,26,22,17,26,109;13,63,11,10,23,63]';
Def:= [69,56,69,201,60,28;44,28,32,132,132,56;130,83,23,72,81,35]';
OSpez:=[50,19,119;109,33,17;25,148,49;79,20,148;120,61,8;28,180,89];
DSpez:=[46,28,76; 65,30,19; 23,51,30; 32,23,49; 63,28,21; 25,39,30];
comment
Angriffs- bzw. Verteidigungsstärke für Spezialeinheiten
Belagerungsturm, Balliste, Tribok;
Berserker, Nord. Bogenschütze, Axtreiter
endcomment
lSK:=["oI","oA","oK","dI","dA","dK"];
lKL=["I","A","K"];
lTR:=["ST","SK","BS","AS","PR","LR"]; 
lRS:=["H","S","E"]; 
A:=Off[[2,3,6]]';
//Umformungsmatrix
U:=[0,0,0,0,0,0;1,0,0,0,0,0;0,1,0,0,0,0;0,0,0,0,0,0;0,0,0,0,0,0;0,0,1,0,0,0];
U2:=[0,1,0,0,0,0;0,0,1,0,0,0;0,0,0,0,0,1];

function fight(a,d)
## berechnet sämtliche Kampfrunden
## ([aST,aSK,aBS,aAS,aPR,aLR],[dST,dSK,dBS,dAS,dPR,dLR])
global A, Off, Def, lTR;
TblA:=a; TblD:=d;
repeat;
rA:=a.Off; rD:= d.Def+1000; key:=rD/rA;
loss:=key_1/key; loss:=mset(loss,mnonzeros(loss>1),ones(2,3));
lA:=flatten(dup(loss[1],2)'); lD:=flatten(dup(loss[2],2)');
a:=floor((1-lA/2)*a); d:=floor((1-lD/2)*d);
TblA:=TblA_a; TblD:=TblD_d;
until (sum(a)<=49||sum(d)<=49)
end
writetable(([0:rows(TblA)-1])'|TblA|sum(TblA),wc=8,labc="Rnd"+lTR+"Sum"), writeln; ...
writetable(([0:rows(TblD)-1])'|TblD|sum(TblD),wc=8,labc="Rnd"+lTR+"Sum")
return {TblA, TblD};
endfunction

function fight2(At,d)
## berechnet sämtliche Kampfrunden
## ([aST,aSK,aBS,aAS,aPR,aLR],[dST,dSK,dBS,dAS,dPR,dLR])
global A, Off, Def, lTR;
TblA:=At; TblD:=d;
repeat;
rA:=At.Off; rD:= 1.2*d.Def+8000; key:=rD/rA;
loss:=key_1/key; loss:=mset(loss,mnonzeros(loss>1),ones(2,3));
lA:=flatten(dup(loss[1],2)'); lD:=flatten(dup(loss[2],2)');
At:=floor((1-lA/2)*At); d:=floor((1-lD/2)*d);
TblA:=TblA_At; TblD:=TblD_d;
until (sum(At)<=249||sum(d)<=249)
end
writetable(([0:rows(TblA)-1])'|TblA|sum(TblA),wc=8,labc="Rnd"+lTR+"Sum"), writeln; ...
writetable(([0:rows(TblD)-1])'|TblD|sum(TblD),wc=8,labc="Rnd"+lTR+"Sum");
return {TblA, TblD};
endfunction

function bat(a,rD)
## berechnet Kampfausgang
## ([aST,aSK,aBS,aAS,aPR,aLR],[rDi,rDa,rDk])
global Off, Def, lTR, lKL;
rA:=a.Off; key:=rD/rA;
loss:=key_1/key; loss:=mset(loss,mnonzeros(loss>1),ones(2,3));
lA:=flatten(dup(loss[1],2)'); lD:=flatten(dup(loss[2],2)');
vA:=ceil(lA*a);
t:=a[[2,3,6]]_vA[[2,3,6]]_rA_rD_rA-rD_1/key_key; 
writetable(t|sum(t),labc=lKL+"sum",wc=14, ..
labr=["x","loss","rA","rD","rA-rD","Schaden","Verlust"]);
return key;
endfunction

function Silber(Silber,Anz,Kapaz=[1450,200,20])
SpVerm=Anz*Kapaz; SpVerm=SpVerm|sum(SpVerm);
hilf=[25,5,1];
Bedarf=Anz.hilf'*hilf|0;
Ideal=2*(Silber-Bedarf)/sum(SpVerm);
Bedarf[4]=Silber;
M=Ideal'.Kapaz; M=M[1:3,]|M[4,]';
tmp=Anz_Kapaz_SpVerm_200*SpVerm/sum(SpVerm)_Bedarf_Ideal*100_M;
lHR=["Stadt","Festung","Burg"];
writetable(tmp,wc=13, dc=1,labr=["Anz","Kapaz/Habitat","Fassvermögen", ..
"Fassung [%]","Silber","Ideal [%]"+lHR], labc=lHR+"Total")
return Ideal;
endfunction

function simDia(A,b)
global A, rD;
f:=round(max(rD')/100,-2)*2;
figure(2,2);
figure (1); xa:=feasibleArea(A[,[1,2]],b,eq=-1);
plot2d(xa[1],xa[2],filled=1,style="/",a=0,b=f,c=0,d=f);
plot2d("rD[2]/rD[1]*x",>add);
figure (2); plot2d([1:3],rD',>bar);
figure (3); xa:=feasibleArea(A[,[1,3]],b,eq=-1);
plot2d(xa[1],xa[2],filled=1,style="/",a=0,b=f,c=0,d=f);
plot2d("rD[3]/rD[1]*x",>add);
figure(4); xa:=feasibleArea(A[,[2,3]],b,eq=-1);
plot2d(xa[1],xa[2],filled=1,style="/",a=0,b=f,c=0,d=f);
plot2d("rD[3]/rD[2]*x",>add); 
figure(0);
endfunction

// Missionen
Kos:= [18,6,30;43,20,48;27,12,39;50,28,55;25,15,45;70,60,80];
M:=100*[[.2,.4,.3,0,0,0];[.7,.7,.7,0,.3,0];[2,2,0,1,.5,0];[0,1,1.5,0,.5,1];[1,1,1,1,0,0];[1,0,0,1,1,1]];
MR:=[[~60,120~,~100,200~,~60,120~];[~750,1500~,~750,1500~,~1250,2500~];[~920,2300~,~920,2300~,~1200,3000~];
[~300,1500~,~300,1500~,~520,2600~];[~800,1000~,~800,1000~,~1600,2000~];[~960,1600~,~960,1600~,~1920,3200~]];
lMS:=["Werkzeug", "Kontor", "Steuern", "Räuber", "Burg", "Ritter"];

//Gewichtungsmatrizen
Poff&:=[[0,0,0,0,81,35]/63;[69,56,0,0,0,0]/66;[0,0,32,132,0,0]/109]';
Pdef&:=[[0,0,0,0,60,28]/43;[44,28,0,0,0,0]/22;[0,0,23,72,0,0]/63]';
Pf&:=1000/[43,22,63];

function TraLK([x,y]):=[(x-16294)*1609-470000,(y+16440)*1609+7858500];



