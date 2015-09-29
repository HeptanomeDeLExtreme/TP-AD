function P1(varargin)
% Gère la Partie 1 du TP d'Aide à la Décision
% Auteurs : Hexanome 4203
% Date : 29-sept-2015

%% Variables
% Temps unitaire d'usinage d'un produit
T1 = [  8   7   8   2   5   5   5;...
    15  12  1   10  0   5   3;...
    0   2   11  5   8   3   5;...
    5   15  0   4   7   12  8;...
    0   7   10  13  10  8   0;...
    10  12  25  7   25  6   7];

% Quantité de matière première par produit
T2 = [  1   2   1   5   0   2;...
    2   2   1   2   2   1;...
    1   0   3   2   2   0];

% Quantité max. de matière première
T3 = [  350 620 485];

% Prix de vente des produits finis
T4 = [  20  27  26  30  45  40];

% Prix d'achat des matières premières
T4bis=[ 3   4   2   ];

% Coût horaire des machines
T5=[2 2 1 1 2 3 1];

% Temps d'étude
t_max = 4800;

% Variables de linprog
A(1:7, 1:6)=T1';
A(8:10, 1:6)=T2;
B=[t_max;t_max;t_max;t_max;t_max;t_max;t_max;T3(1);T3(2);T3(3)];
lb=[ 5 5 0 0 0 0];
ub = ones(1,6)*10000000;

% En cas de contrainte supplémentaire
A2=[A; ones(1,6)*-1];
B2=[B; -300];

%% Comptable
% On cherche ici à maximiser les bénéfices
Cout_USIN = zeros(1,6);
Cout_MP = zeros(1,6);

for it_produit=1:6
    for it_machine=1:7
        Cout_USIN(it_produit)=Cout_USIN(it_produit)+(T1(it_produit, it_machine)*T5(it_machine)/60);
    end
    for it_MP=1:3
        Cout_MP(it_produit) = Cout_MP(it_produit) + T2(it_MP, it_produit)*T4bis(it_MP);
    end
end

Benefices = T4-Cout_USIN-Cout_MP;

f=-Benefices;
[x, val] = linprog(f,A,B,[],[],lb,ub);
assignin('base', 'X_COMPTABLE', x);
assignin('base', 'MAX_COMPTABLE', -val);

%% Responsable Atelier
% On cherche ici à maximiser le nombre de pièces produites
f=ones(1,6)*-1;
[x, val] = linprog(f,A,B,[],[],lb,ub);
assignin('base', 'X_RESP_ATELIER', x);
assignin('base', 'MAX_RESP_ATELIER', -val);

%% Responsable des stocks
f=[4 4 5 9 4 3] +1;
[x, val] = linprog(f,A2,B2,[],[],lb,ub);
assignin('base', 'X_RESP_STOCK', x);
assignin('base', 'MIN_RESP_STOCK', val);

%% Responsable commercial
f=[-1 0 0 0 -1 0];
Aeq=[1 0 0 0 -1 0];
Beq=0;
[x, val] = linprog(f,A,B,Aeq,Beq,lb,ub);
assignin('base', 'X_RESP_COM', x);
assignin('base', 'MAX_RESP_COM', -val);

%% Responsable du personnel
f=[2 10 5 4 13 7];
[x, val] = linprog(f,A2,B2,[],[],lb);
assignin('base', 'X_RESP_PERSONNEL', x);
assignin('base', 'MIN_RESP_PERSONNEL', val);

end