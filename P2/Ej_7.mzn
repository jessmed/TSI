include "globals.mzn";

% Declaramos los conjuntos con los que vamos a trabajar
set of int : tareas = 1..12;
set of int : tam = 1..2;

% Variables para operar e imprimir correctamente la solucion
% serán 4 arrays que guardaran:
% - la duración de cada tarea
% - el momento en que empieza cada tarea
% - cuanto dura cada tarea
% - las tareas predecesores que tienen que estar hechas antes
var int: tiempo_minimo ;
array[tareas,tam] of var int: predecesores=[| 0,0 | 1,0 | 2,0 | 3,0 | 4,0 | 4,0 | 4,5 | 3,0 | 5,6 | 5,6 | 9,10 | 11,0 |];
array[tareas] of var string: nombres_tareas=["A","B","C","D","E","F","G","H","I","J","K","L"];
array[tareas] of var int : duracion=[60,10,5,5,5,2,7,3,7,2,5,1];
array[tareas] of var int : tiempos;


% Función que calcula el tiempo de compienzo para cada tarea
function var int : tiempo(var int : tarea) = if max([predecesores[tarea,k]  | k in tam]) == 0 then 1 else if(predecesores[tarea,1]) == 0 then 
duracion[predecesores[tarea,2]] else if(predecesores[tarea,2]) == 0 then duracion[predecesores[tarea,1]]+tiempos[predecesores[tarea,1]] else tiempos[predecesores[tarea,1]]+duracion[predecesores[tarea,1]]+duracion[predecesores[tarea,2]] endif endif endif;

% Restricciones para saber el tiempo minimo final y para aplicar la funcion a todas las tareas
constraint forall(i in tareas)(tiempos[i] >= tiempo(i));
constraint tiempo_minimo == tiempos[12] + duracion[12];

% Resolvemos
solve satisfy;

% Salida por pantalla
output["TIEMPO MINIMO = \(tiempo_minimo) \n "] ++ ["Tarea \(nombres_tareas[i]) empieza en tiempo \(tiempos[i]) \n" | i in tareas];