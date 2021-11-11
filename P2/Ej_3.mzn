include "globals.mzn";

% Array con los nombres de los paises
array[1..13] of string : paises = ["Argentina","Bolivia","Brasil","Chile","Colombia","Ecuador","Guayana Francesa","Guayana","Paraguay","Perú","Surinam","Uruguay","Venezuela"];

% Array con colores de los paises longitud número de paises que pueden tomar colores del 1 al 5
array[1..13] of var 1..5: colores;
array[1..5] of var string: nombres_colores = ["Verde","Naranja","Rojo","Azul","Amarillo"];

% Array de precios de los colores
array[1..5] of int: precios = [100,200,300,400,500];



% Restricciones paises limítrofes

% Argentina
constraint colores[1] != colores[2] /\ colores[1] != colores[3] /\ colores[1] != colores[4] /\ colores[1] != colores[9] /\ colores[1] != colores[12];
% Bolivia
constraint colores[2] != colores[1] /\ colores[2] != colores[3] /\ colores[2] != colores[4] /\ colores[2] != colores[9] /\ colores[2] != colores[10];
% Brasil
constraint colores[3] != colores[1] /\ colores[3] != colores[2] /\ colores[3] != colores[5] /\ colores[3] != colores[7] /\ colores[3] != colores[9] /\ colores[3] != colores[10] /\ colores[3] != colores[11] /\ colores[3] != colores[12] /\ colores[3] != colores[13];
% Chile
constraint colores[4] != colores[1] /\ colores[4] != colores[2] /\ colores[4] != colores[10];
% Colombia
constraint colores[5] != colores[3] /\ colores[5] != colores[6] /\ colores[5] != colores[10] /\ colores[5] != colores[13];
% Ecuador
constraint colores[6] != colores[5] /\ colores[6] != colores[10];
% Guayana Francesa
constraint colores[7] != colores[3] /\ colores[7] != colores[11];
% Guyana
constraint colores[8] != colores[3] /\ colores[8] != colores[11] /\ colores[8] != colores[13];
% Paraguay
constraint colores[9] != colores[1] /\ colores[9] != colores[2] /\ colores[9] != colores[3] /\ colores[9] != colores[12];
% Perú
constraint colores[10] != colores[2] /\ colores[10] != colores[3] /\ colores[10] != colores[4] /\ colores[10] != colores[5] /\ colores[10] != colores[6];
% Surinam
constraint colores[11] != colores[3] /\ colores[11] != colores[7] /\ colores[11] != colores[8];
% Uruguay
constraint colores[12] != colores[1] /\ colores[12] != colores[3] /\ colores[12] != colores[10];
% Venezuela
constraint colores[13] != colores[3] /\ colores[13] != colores[5] /\ colores[13] != colores[8];

% Variable del coste total del coloreado
var int: coste_total;

% El coste total que queremos es la suma de los costes de cada color, como los costes coinciden con el
% indice asignado al color en una escala 100 veces menor de forma que 1->100 2->200 3->300 4->400 5->500
% directamente he sumado el indice de los colores y lo he minimizado, más tarde para mostrar el coste real
% de cada color multiplicare su indice de color por 100 y asi me ahorro mucho codigo redundante
coste_total = sum(colores);

% Imprimimos por pantalla el pais, su color y su coste(que es el número de su color * 100)
output ["total: \(coste_total*100)\n"];
output ["\(paises[i]): \(nombres_colores[fix(colores[i])]) \(colores[i] * 100)\n" | i in 1..13];


% Resolvemos minimizando el coste total del coloreado
solve minimize coste_total;