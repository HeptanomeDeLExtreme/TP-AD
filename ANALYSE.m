function ANALYSE(varargin)
% TP Aide a la Decision
% Auteurs : Hexanome 4203
% Date : 29-sept-2015 -> 13-oct-2015

%% Variables utiles *******************************************************
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

% Matrice des jugements
T6_old = [  6   5   5   5;...
    5   2   6   7;...
    3   4   7   3;...
    3   7   5   4;...
    5   4   3   9;...
    2   5   7   3;.... % Ligne dominée
    5   4   2   9;.... % Ligne dominée
    3   5   7   4];

T6 = [  6   5   5   5;...
    5   2   6   7;...
    3   4   7   3;...
    3   7   5   4;...
    5   4   3   9;...
    3   5   7   4];

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

s_concorde = 2.5/4;
s_discorde = 2/10;

%% Partie 1 : Objectifs des différents responsables ***********************
% Dans cette section, on cherche la solution qui satisfait au mieux chacun
% des responsables de l'entreprise indépendamment des autres.

% Comptable ---------------------------------------------------------------
% Le comptable cherche à maximiser les benefices générés.
Benefices = T4-Cout_USIN-Cout_MP;

f=-Benefices;
[X_C,~] = linprog(f,A,B,[],[],lb,ub);
assignin('base', 'X_C', X_C);
    function [gain] = G(X)
        gain = abs(X(1)*5.833 + X(2)*11.617 + X(3)*12.17 + X(4)*1.3 + X(5)*31.65 + X(6)*27.48);
    end

% Responsable Atelier -----------------------------------------------------
% On cherche ici à maximiser le nombre de pièces produites
f=ones(1,6)*-1;
[X_RA,~] = linprog(f,A,B,[],[],lb,ub);
assignin('base', 'X_RA', X_RA);
    function [gain] = F(X)
        gain = abs(X(1) + X(2) + X(3) + X(4) + X(5) + X(6));
    end

% Responsable des stocks --------------------------------------------------
f=[4 4 5 9 4 3] +1;
[X_RS,~] = linprog(f,A2,B2,[],[],lb,ub);
assignin('base', 'X_RS', X_RS);
    function [gain] = H(X)
        gain = abs(-(5*X(1) + 5*X(2) + 6*X(3) + 10*X(4) + 5*X(5) + 4*X(6)));
    end

% Responsable commercial -------------------------------------------------
f=-ones(1,6);
Aeq=[1 0 0 0 -1 0];
Beq=0;
[X_COM,~] = linprog(f,A,B,Aeq,Beq,lb,ub);
assignin('base', 'X_COM', X_COM);
    function [gain] = K(X)
        gain = abs(X(1) - X(5));
    end

% Responsable du personnel ------------------------------------------------
f=[2 10 5 4 13 7];
[X_RP,~] = linprog(f,A2,B2,[],[],lb);
assignin('base', 'X_RP', X_RP);
    function [gain] = J(X)
        gain = abs(-(2*X(1) + 10*X(2) + 5*X(3) + 4*X(4) + 13*X(5) + 7*X(6)));
    end

%% Partie 2 : Vision du responsable d'entreprise
% Dans cette section, on fait de la programmation linéaire multicritère
% pour trouver une solution qui satisfait au mieux tous les objectifs des
% responsables de l'entreprise

% Calcul de la matrice de gains
Matrice_Gains = [ F(X_RA) G(X_RA) H(X_RA) J(X_RA) K(X_RA);...
    F(X_C) G(X_C) H(X_C) J(X_C) K(X_C);...
    F(X_RS) G(X_RS) H(X_RS) J(X_RS) K(X_RS);...
    F(X_RP) G(X_RP) H(X_RP) J(X_RP) K(X_RP);...
    F(X_COM) G(X_COM) H(X_COM) J(X_COM) K(X_COM)];

assignin('base','MAT_GAINS',Matrice_Gains);


%  Ici on n'a gardé qu'un critère et transformé les autres en contraintes
%  Afin de se rapprocher du point optimal, on procède par dichotomie.
f=-Benefices;
Aeq=[1 0 0 0 -1 0];
Beq=0;

% Transformation des critères en contraintes
contrainteTrasforme = [-1 -1 -1 -1 -1 -1;... % Resp Atelier
    5 5 6 10 5 4;... % Resp Stock
    2 10 5 4 13 7;... % Resp Personnel
    -1 -1 -1 -1 -1]% Resp commercial; %%% EQUATION A CHANGER

% Construction des matrices A et B
A(1:7, 1:6)=T1';
A(8:10, 1:6)=T2;
A(11:13, 1:6)=contrainteTrasforme;
B=[4800;4800;4800;4800;4800;4800;4800;350;620;485;-350;1680;2508.8;-x4]; %%% -x4 A CHANGER

% Résolution du problème
[X_CHEF,~] = linprog(f,A,B,Aeq,Beq,lb);
assignin('base','X_CHEF',X_CHEF);

%% Partie 3a : Analyse multicritère sans pondération
% Dans cette section, on a 8 propositions à analyser à partir de 4 critères
% d'étude. On cherche la meilleure, d'abord sans hiérarchiser les critères.

% Dans l'étude préliminaire, on élimine les propositions F et G, dominées
% par les autres.

% Matrice de concordance
Concorde = zeros(6); % Propositions A B C D E H
for no_ligne=1:6
    for no_colonne=1:6
        if no_ligne==no_colonne
            Concorde(no_ligne,no_colonne)=-1;
        else
            coef=0;
            for no_iter=1:4
                if T6(no_ligne,no_iter)>=T6(no_colonne,no_iter)
                    coef=coef+1;
                end
            end
            coef=coef/4;
            Concorde(no_ligne,no_colonne)=coef;
        end
    end
end
assignin('base','CONCORDE_NEUTRE',Concorde);

% Matrice de discordance
Discorde = zeros(6); % a b c d e h
echmax = 10;
for no_ligne=1:6
    for no_colonne=1:6
        if no_ligne==no_colonne
            Discorde(no_ligne,no_colonne)=-1;
        else
            coef=0;
            for no_iter=1:4
                if T6(no_ligne,no_iter)<T6(no_colonne,no_iter)
                    coef=[coef; T6(no_colonne,no_iter)-T6(no_ligne,no_iter)];
                end
            end
            coef=max(coef)/echmax;
            Discorde(no_ligne,no_colonne)=coef;
        end
    end
end
assignin('base','DISCORDE',Discorde);

Graphe = zeros(size(Concorde,1),size(Concorde,2));
for no_ligne=1:size(Concorde,1)
    for no_col=1:size(Concorde,2)
        if Concorde(no_ligne, no_col)>=s_concorde
            Graphe(no_ligne, no_col)=Graphe(no_ligne, no_col)+1;
        end
        if Discorde(no_ligne, no_col)<=s_discorde
            Graphe(no_ligne, no_col)=Graphe(no_ligne, no_col)+1;
        end
        if Graphe(no_ligne, no_col)<2
            Graphe(no_ligne, no_col)=0;
        else
            Graphe(no_ligne, no_col)=1;
        end
    end
end

assignin('base','G_NEUTRE',Graphe);

G_= biograph(Graphe,{'A','B','C','D','E','H'},'Label','Graphe de surclassement');
view(G_);

%% Partie 3b : Analyse multicritère avec pondération
% On hiérarchise cette fois les critères

% Matrice de concordance
Concorde = zeros(6); % A B C D E H
Ponderation = [4 2 2 1];
for no_ligne=1:6
    for no_colonne=1:6
        if no_ligne==no_colonne
            Concorde(no_ligne,no_colonne)=-1;
        else
            coef=0;
            for no_iter=1:4
                if T6(no_ligne,no_iter)>=T6(no_colonne,no_iter)
                    coef=coef+Ponderation(no_iter);
                end
            end
            coef=coef/(sum(Ponderation));
            Concorde(no_ligne,no_colonne)=coef;
        end
    end
end

assignin('base','CONCORDE_POND',Concorde);

s_concorde = 0.75;
s_discorde = 0.5;

Graphe = zeros(size(Concorde,1),size(Concorde,2));
for no_ligne=1:size(Concorde,1)
    for no_col=1:size(Concorde,2)
        if Concorde(no_ligne, no_col)>=s_concorde
            Graphe(no_ligne, no_col)=Graphe(no_ligne, no_col)+1;
        end
        if Discorde(no_ligne, no_col)<=s_discorde
            Graphe(no_ligne, no_col)=Graphe(no_ligne, no_col)+1;
        end
        if Graphe(no_ligne, no_col)<2
            Graphe(no_ligne, no_col)=0;
        else
            Graphe(no_ligne, no_col)=1;
        end
    end
end

assignin('base','G_POND',Graphe);
G2= biograph(Graphe,{'A','B','C','D','E','H'});
view(G2);

end
