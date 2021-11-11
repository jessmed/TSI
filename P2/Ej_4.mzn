include "globals.mzn";


% Definimos las constante dia

% Definimos el array donde estaran las letras el array tendrá longitud 9 y cada posición podrá tomar valores de 0 a 9
array[1..7] of string: dias_semana=["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"];
array[1..7] of string: personas = ["Juan","María","Carmen","Francisco","Marta","Olga","Pepe"];

% Array de veracidad de emisores 1=True, 0=1
array[1..7] of var 0..1:verdades;

var 1..7:dia;


% Se tiene que cumplir que la suma de todas las veracidades sea 1
constraint if dia=2 then verdades[1]=1 else verdades[1]=0 endif;
constraint if dia=1 then verdades[2]=1 else verdades[2]=0 endif;
constraint if dia=3 then verdades[3]=1 else verdades[3]=0 endif;
constraint if dia=7 then verdades[4]=1 else verdades[4]=0 endif;
constraint if dia=5 \/ dia=4 then verdades[5]=1 else verdades[5]=0 endif;
constraint if dia=7 then verdades[6]=1 else verdades[6]=0 endif;
constraint if dia!=7 then verdades[7]=1 else verdades[7]=0 endif;

constraint (verdades[1]+verdades[2]+verdades[3]+verdades[4]+verdades[5]+verdades[6]+verdades[7]) == 1;



% Imprimimos por pantalla la solución obtenida
output ["hoy: \(dias_semana[fix(dia)])\n"];
       
% % Imprimimos el nombre de la persona que emitió afirmación correcta
output ["emisor: "] ++
       [if fix(verdades[i])==1 then "\(personas[i])" else "" endif | i in 1..7];



% Resolvemos
solve satisfy;