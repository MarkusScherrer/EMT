// Formeln und Konstanten für L+K

comment
Ordnung der Indizes: I, A, K, bzw.
ST, SK, BS, AS, PR, LR
endcomment

Off:= [7,43,66,23,16,36;5,26,22,16,26,109;13,62,11,10,23,62]';
Def:= [69,55,69,201,60,28;44,28,32,132,132,55;129,83,23,72,81,34]';
Kos:= [18,6,30;43,20,48;27,12,39;50,28,55;25,15,45;55,45,110];
M:=100*[[2,2,2,2,0,0];[0.5,0.5,0.5,0,0,0];[0,2,3,0,1,2];[2,0,0,2,2,2];[4,4,0,2,1,0]];
lSK:=["oI","oA","oK","dI","dA","dK"];
lKL=["I","A","K"];
lTR:=["ST","SK","BS","AS","PR","LR"]; lRS:=["H","S","E"]; 
lMS:=["Burgfest", "Markttag", "Räuber", "Ritter", "Steuern"];
A:=Off[[2,3,6]]';
P1&:=[[0,0,0,0,81,34]/62;[69,55,0,0,0,0]/66;[0,0,32,132,0,0]/109]';
P2&:=[[0,0,0,0,60,28]/43;[44,28,0,0,0,0]/22;[0,0,23,72,0,0]/62]';
Pf&:=1000/[43,22,62];
U:=[0,0,0,0,0,0;1,0,0,0,0,0;0,1,0,0,0,0;0,0,0,0,0,0;0,0,0,0,0,0;0,0,1,0,0,0];

function fight(A=At,D=Df)
global A, Off, Def, lTR;
TblA:=A; TblD:=D;
repeat;
rA:=A.Off; rD:=1*(D.Def+1000*[1,1,1]); key:=rD/rA;
loss:=key_1/key; loss:=mset(loss,mnonzeros(loss>1),ones(2,3));
lA:=flatten(dup(loss[1],2)'); lD:=flatten(dup(loss[2],2)');
A:=floor((1-lA/2)*A); D:=floor((1-lD/2)*D);
TblA:=TblA_A; TblD:=TblD_D;
until (sum(A)<=49||sum(D)<=49)
end
writetable(([0:rows(TblA)-1])'|TblA|sum(TblA),wc=8,labc="Rnd"+lTR+"Sum"), writeln; ...
writetable(([0:rows(TblD)-1])'|TblD|sum(TblD),wc=8,labc="Rnd"+lTR+"Sum")
return {TblA, TblD}
endfunction

function bat(A=At, D=Df)
global Off, Def, lTR, lKL;
rA:=A.Off; rD:=1*(D.Def+1000*[1,1,1]); key:=rD/rA;
loss:=key_1/key; loss:=mset(loss,mnonzeros(loss>1),ones(2,3));
lA:=flatten(dup(loss[1],2)'); lD:=flatten(dup(loss[2],2)');
vA:=ceil(lA*A); vD:=ceil(lD*D);
t:=A[[2,3,6]]_vA[[2,3,6]]_rA_rD_rA-rD_key_1/key; 
writetable(t|sum(t),labc=lKL+"sum",wc=14,labr=["x","loss","rA","rD","rA-rD","rA/rD","rD/rA"]);
return {rA,rD,key,vA}
endfunction


comment
Fortification: [10, 50, 100, 150, ..., 950, 1000] bzw.
[0.05, 0.10, 0.15, ..., 0.90, 1]
endcomment