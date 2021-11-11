include "globals.mzn";

% Conjuntos numero de pacientes y tamaño del conjunto de sintomas
set of int: pacientes = 1..20;
set of int: tam = 1..4;

% Base de datos de pacientes y sintomas
array[pacientes,tam] of int: base_de_datos = [| 0,0,1,1 | 1,1,1,0 | 1,1,0,1 | 1,0,0,1 | 1,1,0,1 | 0,1,1,1 | 1,0,0,0 | 
1,1,0,0 | 0,1,0,0 | 0,0,1,1 | 1,0,0,1 | 1,0,0,1 | 0,1,1,0 | 1,1,0,0 | 1,0,1,0 | 1,0,0,0 | 1,0,0,1 | 0,1,1,0 | 0,0,1,0 | 1,0,1,0|];

% Array de diagnóstico de cada paciente con valores del 1 al 3 que pueden ser
% 1="COVID" , 2 = "Gripe" o 3 = "Alergias")
array[pacientes] of var int: diagnosticos = [1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3];

% Variable dle nuevo paciente que vamos a estuiar
array[tam] of var int: nuevo_paciente = [0,1,1,1];

% Variables para calcular las distancias y el diagnostico final
array[pacientes] of var int : distancias ;
var int: indice ;
var string : diagnostico_nuevo_paciente;


% Calcular la distancia entre dos pacientes.
predicate distancia(array[int,int] of int: a, array[int] of var int: v, var int:d , var int: j) =
  d = sum(i in tam) ((a[j,i]-v[i])*(a[j,i]-v[i])) /\ d >= 0 ;
 
% Recuperar el índice del menor valor de un array (i.e. argmin)

predicate indice_minimo(var int: mi, array[int] of var int: x) = exists(i in index_set(x)) (x[i] = min(x) /\ mi = i);


% Restricciones para aplicar los predicados 
constraint forall(i in pacientes)(distancia(base_de_datos,nuevo_paciente,distancias[i],i));
constraint indice_minimo(indice,distancias);

% Resolvemos
solve satisfy;

% Imprimimos por pantalla
output["Distancia a cada paciente :" ] ++ [" \(distancias[i]) " | i in pacientes] ++ ["\nEl paciente más parecido es el paciente \(indice)\n"] ++ ["\nEl diagnóstico más probable es: "] ++ [if fix(diagnosticos[indice])==1 then "COVID" elseif fix(diagnosticos[indice]) == 2 then "Gripe" else "Alergias" endif ];