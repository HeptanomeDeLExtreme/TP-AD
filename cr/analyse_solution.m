function ANA_SOL(X)
% Analyse une solution par rapport aux objectifs de chacun des responsables
% de l'entreprise.

%% Variables
% Temps unitaire d'usinage d'un produit
T1 = [  8   7   8   2   5   5   5;...
    15  12  1   10  0   5   3;...
    0   2   11  5   8   3   5;...
    5   15  0   4   7   12  8;...
    0   7   10  13  10  8   0;...
    10  12  25  7   25  6   7];

% Quantite de matiere premiere par produit
T2 = [  1   2   1   5   0   2;...
    2   2   1   2   2   1;...
    1   0   3   2   2   0];

% Quantite max. de matiere premiere
T3 = [  350 620 485];

% Prix de vente des produits finis
T4 = [  20  27  26  30  45  40];

% Prix d'achat des matieres premieres
T4bis=[ 3   4   2   ];

% Cout horaire des machines
T5=[2 2 1 1 2 3 1];


fprintf('----- Solution -------------------------------------\n');
fprintf(['     Produits A :' num2str(X(1),'%6.2f') ' unites. \n']);
fprintf(['     Produits B :' num2str(X(2),'%6.2f') ' unites. \n']);
fprintf(['     Produits C :' num2str(X(3),'%6.2f') ' unites. \n']);
fprintf(['     Produits D :' num2str(X(4),'%6.2f') ' unites. \n']);
fprintf(['     Produits E :' num2str(X(5),'%6.2f') ' unites. \n']);
fprintf(['     Produits F :' num2str(X(6),'%6.2f') ' unites. \n']);

fprintf('----- Analyse de la solution -----------------------\n');
%% Comptable
% On cherche ici a maximiser les benefices
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

Argent = 0;
for no_produit=1:6
    Argent = Argent + Benefices(no_produit)*X(no_produit);
end
fprintf(['Benefices : ' num2str(Argent,'%6.2f') '\n']);

%% Responsable Atelier
% On cherche ici a maximiser le nombre de pieces produites
fprintf(['Nombre de produits : ' num2str(sum(X),'%6.2f') '\n']);

%% Responsable des stocks
f=[4 4 5 9 4 3] +1;
ut_stock=0;
for no_produit=1:6
    ut_stock=ut_stock+f(no_produit)*X(no_produit);
end
fprintf(['Utilisation de l''espace de stockage : ' num2str(ut_stock,'%6.2f') ' unites\n']);

%% Responsable commercial
fprintf(['Difference de production A/E : ' num2str(abs(X(1)-X(5)),'%6.2f') '\n']);

%% Responsable du personnel
f=[2 10 5 4 13 7];
ut_mac_4=0;
for no_produit=1:6
    ut_mac_4=ut_mac_4+f(no_produit)*X(no_produit);
end
fprintf(['Utilisation de la machine 4 : ' num2str(ut_mac_4,'%6.2f') ' min\n']);

fprintf('----------------------------------------------------\n\n');
end

