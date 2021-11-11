include "globals.mzn";


% Definimos las constantes letras con su valor en el array, es decir, por ejemplo la S será la posición 0 en el array
int : S = 0;
int : I = 1;
int : X = 2;
int : E = 3;
int : V = 4;
int : N = 5;
int : T = 6;
int : W = 7;
int : Y = 8;

% Definimos el array donde estaran las letras el array tendrá longitud 9 y cada posición podrá tomar valores de 0 a 9
array[0..8] of var 0..9: letras;

% Definimos las variables para gestionar el acarreo a la hora de hacer la suma
var int : acarreo; var int : acarreo2; var int : acarreo3; var int : acarreo4; var int : acarreo5;

% Creamos la restricción alldiferent que nos asegura que los valores de las letras serán disintos
constraint alldifferent(letras);

% Creamos restricciones a partir de las sumas que se nos piden y haciendo modulo 10 para que esten
% entre 0..9, luego calculamos el acarreo para la siguiente suma usando div 10
constraint (letras[X] + letras[N] + letras[N]) mod 10 == letras[Y];
acarreo = (letras[X] + letras[N] + letras[N]) div 10;

constraint (letras[I] + letras[E] + letras[E] + acarreo) mod 10 == letras[T];
acarreo2 = (letras[I] + letras[E] + letras[E] + acarreo) div 10;

constraint (letras[S] + letras[V] + letras[V] + acarreo2) mod 10 == letras[N];
acarreo3 = (letras[S] + letras[V] + letras[V] + acarreo2) div 10;


constraint (letras[E] + letras[E] + acarreo3) mod 10 == letras[E];
acarreo4 = (letras[E] + letras[E] + acarreo3) div 10;

constraint (letras[S] + letras[S] + acarreo4) mod 10 == letras[W];
acarreo5 = (letras[S] + letras[S] + acarreo4) div 10;

% Finalmente T debe corresponderse con el acarreo5 de la última operacion
constraint letras[T] == acarreo5;

% Imprimimos por pantalla la solución obtenida
output ["Solución: \n"];
output ["\t S: \(letras[S])\n"];
output ["\t I: \(letras[I])\n"];
output ["\t X: \(letras[X])\n"];
output ["\t E: \(letras[E])\n"];
output ["\t V: \(letras[V])\n"];
output ["\t N: \(letras[N])\n"];
output ["\t T: \(letras[T])\n"];
output ["\t W: \(letras[W])\n"];
output ["\t Y: \(letras[Y])\n\n"];


output ["\t\t     SIX \t\t     \(letras[S])\(letras[I])\(letras[X])\n"];
output ["\t\t + SEVEN \t\t + \(letras[S])\(letras[E])\(letras[V])\(letras[E])\(letras[N])\n"];
output ["\t\t + SEVEN \t\t + \(letras[S])\(letras[E])\(letras[V])\(letras[E])\(letras[N])\n"];
output ["\t\t======== \t\t ========\n"];
output ["\t\t  TWENTY \t\t  \(letras[T])\(letras[W])\(letras[E])\(letras[N])\(letras[T])\(letras[Y])\n"];


% Resolvemos
solve satisfy;