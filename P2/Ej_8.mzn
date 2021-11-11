include "globals.mzn";

set of int : tareas = 1..9;

% duraciones de las tareas, dadas en el enunciado
array[tareas] of var int : duracion = [7, 3, 1, 8, 2, 1, 1, 3, 2];
var int : coste;


% como se que tienen que estar en orden, como algunas tienen dos predecesoras, usamos un array2d, las introduciremos siempre en orden ascendente, es decir,
% la segunda posición tiene que ser la tarea con mayor indice
array[tareas, 1..2] of var int : predecesoras = [| 0,0 | 1,1 | 2,2 | 1,1 | 3,4 | 3,4 | 3,4 | 1,1 | 6,8 |];

% funcion recursiva para calcular el coste de una tarea, básicamente si la tarea no tiene predecesora, devolvemos el coste de la tarea, si no, devolvemos el coste de la tarea con más duración acumulada
function var int : coste(var int : tarea) = if max([predecesoras[tarea, k] | k in 1..2]) == 0 then duracion[tarea] else if coste(predecesoras[tarea, 1]) > coste(predecesoras[tarea, 2]) then duracion[tarea]+coste(predecesoras[tarea, 1]) else  duracion[tarea]+coste(predecesoras[tarea, 2]) endif endif;

% ordenamos las tareas predecesoras (segundo elemento ya que al introducirlas tienen mayor indice)
array[tareas] of var 0..9 : orden = sort([predecesoras[k, 2] | k in tareas]);
array[tareas] of var 1..9 : ordenadas;


% ordenamos los indices comparando los elementos originales y los elementos ordenados, de forma que si uno ya ha aparecido antes, se ejecutaba a la vez, luego tienen el mismo indice
constraint forall(i in tareas)(forall(j in tareas)(if predecesoras[j, 2] == orden[i] /\ not exists(k in 1..i-1)(orden[k] == predecesoras[j, 2]) then ordenadas[j] == i endif) );



% buscamos el coste de la mayor tras ordenarla (+1 ya que al usar las predecesoras ordenadas, ibamos de 0..8, y en duracion usamos 1..9)
constraint coste == coste(orden[9]+1);


output["Orden (si no aparece un número, por ejemplo el 3, es porque se esta realizando en paralelo con otra tarea) : \n\(ordenadas)\n"];
output["Coste: \(coste)"];

solve minimize coste;