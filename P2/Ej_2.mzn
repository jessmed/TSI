include "globals.mzn";

% Declaramos las constantes monedas con su posicion en el array 
int : A = 0;            % Moneda 1 ctms
int : B = 1;            % Moneda 2 ctms
int : C = 2;            % Moneda 5 ctms
int : D = 3;            % Moneda 10 ctms
int : E = 4;            % Moneda 20 ctms
int : F = 5;            % Moneda 50 ctms
int : G = 6;            % Moneda 100 ctms
int : H = 7;            % Moneda 200 ctms
int : cantidad = 799;   % Cantidad de dinero a alcanzar

% Declaramos array de 8 posiciones(8 monedas) las cuales pueden cualquier valor entero
array[0..7] of var 0..9 : monedas;

% Restriccion de que la suma de las monedas multiplicadas cada una por su valor es igual a la cantidad de dinero a alcanzar
constraint monedas[A]+monedas[B]*2+monedas[C]*5+monedas[D]*10+monedas[E]*20+monedas[F]*50+monedas[G]*100+monedas[H]*200 == cantidad;

% Variable de dinero igual a la suma de monedas usadas
var int: suma = sum(monedas);

output ["monedas: \(monedas) \n"];
output ["total monedas: \(suma) "];


% Resolvemos minimizando el número total de monedas
solve minimize suma;