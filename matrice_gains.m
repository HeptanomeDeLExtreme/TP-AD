function [ matrix ] = matrice_gains( X_RA, X_C, X_RS,X_RP)
% Calcul la matrice de gains du TP d'Aide à la Décision
% Auteurs : Hexanome 4203
% Date : 06-oct-2015

%% Calcul de la matrice
matrix = [ F(X_RA) G(X_RA) H(X_RA) J(X_RA);...
           F(X_C)  G(X_C)  H(X_C)  J(X_C);...
           F(X_RS) G(X_RS) H(X_RS) J(X_RS);...
           F(X_RP) G(X_RP) H(X_RP) J(X_RP)];
end


%% Responsable Atelier
function [gain] = F(X)

gain = X(1) + X(2) + X(3) + X(4) + X(5) + X(6);

end

%% Comptable
function [gain] = G(X)

gain = X(1)*5.833 + X(2)*11.617 + X(3)*12.17 + X(4)*1.3 + X(5)*31.65 + X(6)*27.48;

end

%% Responsable des Stocks
function [gain] = H(X)

gain = -(5*X(1) + 5*X(2) + 6*X(3) + 10*X(4) + 5*X(5) + 4*X(6));

end

%% Responsable du Personnel
function [gain] = J(X)

gain = -(2*X(1) + 10*X(2) + 5*X(3) + 4*X(4) + 13*X(5) + 7*X(6));

end
