include "globals.mzn";

% Peso máximo
int : peso_maximo = 5000;

% Número de objetos que tenemos
set of int : num_objetos = 1..12;

% Array con los nombres de los objetos
array[num_objetos] of string : objetos = ["Mapa","Cuchillo","Prismáticos","Agua","Linterna","Cerveza","Novela","Manual de Supervivencia","Platanos","Caramelos","Cerillas","Espejo"];

% Pesos de los objetos segun cada objeto del 1 al 12
array[num_objetos] of int : pesos = [50, 500, 1000, 3000, 1500, 3000, 500, 1000, 2000, 500, 250, 500];

% Preferencias de los objetos de 0 a 100 a mayor valor objeto más útil y necesario
array[num_objetos] of int : preferencias = [100, 90, 75, 95, 85, 10, 5, 70, 90, 20, 50, 40];


% Array de bools de objetos seleccionados longitud 12 representando representa si un objetos es seleccionado(TRUE)
% o si no es seleccionado(FALSE)
array[num_objetos] of var bool : seleccionados;

% Variable para el peso que vamos teniendo conforme añadimos objetos, el valor sera igual a la suma de los pesos de los objetos seleccionados
var int :peso_actual = sum(i in num_objetos)(if seleccionados[i] == true then pesos[i] else 0 endif);

% Restricción para que el peso sea igual o menor al peso máximo
constraint peso_actual <= peso_maximo;

% Variable preferencia que es la suma de todas las preferencias de los objetos seleecionados
var int :preferencia = sum(i in num_objetos)(if seleccionados[i] == true then preferencias[i] else 0 endif);

% Mostramos por pantalla los resultados

% Si un elemento de seleccionados es true imprimimos el objeto que corresponde al índice del elemento en cuestión
% de esta forma como solo imprimimos los indices que son true, imprimimos los objetos seleccionados
output ["Objetos ="] ++
       [if fix(seleccionados[i])==true then "\(objetos[i])" else "" endif | i in num_objetos];

output ["\nPreferencias = \(preferencia) \n"];
output ["PesoFinal = \(peso_actual/1000) kgs\n"];

% Resolvemos maximizando la preferencia
solve maximize preferencia;

