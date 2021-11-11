package src_Medina_Taboada_Jesus;

import java.util.Map;

/*
	Implementaci�n de la clase auxiliar Pair que usaremos en la clase Agent para la estrucutura
	de caminos a la hora de encontrar gemas y que seguir� nuestro agente.
	Principalmente se usar�n en una PriorityQueue de Pairs donde first es un Array de int y second es un double.
	Second es el coste de distancia hasta la gema por lo que al ser una priority queue al usar el m�todo peek
	nos permitira obtener el pair de menor coste.
 
*/
public class Pair<T,U> implements Map.Entry<T, U>, Comparable{

    public T first;
    public U second;

    /*
		Constructor de 'Pair' que recibe atributos first y second
	*/
    public Pair(T first, U second)
    {
        this.first = first;
        this.second = second;
    }

    /*
		Modificaci�n del m�todo 'getKey' para obtener el valor del elatributo first
	*/
    @Override
    public T getKey() {
        return first;
    }

    /*
		Modificaci�n del m�todo 'getValue' para obterner el valor del atributo second
	*/
    @Override
    public U getValue() {
        return second;
    }

    /*
		Modificaci�n del m�todo 'setValue' para establecer un valor en el atributo second
	*/
    @Override
    public U setValue(U value) {
        second = value;
        return second;
    }
    /*
		Modificaci�n del m�todo 'compareTo' para comparar adecuadamente dos instancais de Pair
		primero estima del mayor comparando primero el atributo first y luego el second. Si ambos 
		iguales devuelve un valor de igual. 1=mayor; -1=menor; 0=igual
     */
    @Override
    public int compareTo(Object obj) {

        Pair o = (Pair) obj;
        if ( (Double) o.second > (Double) this.second){
            return -1;
        } else if ((Double) o.second < (Double) this.second){
            return 1;
        } else {
            return 0;
        }
    }

    /*
    	Modificaci�n del m�todo 'equals' para saber de forma correcta si dos instancais de Pair
    	son iguales;compara que sean iguales tanto el atributo first como el second.
    */
    @Override
    public boolean equals(Object obj) {

        return ( ((Pair) obj).first.equals(this.first) &&
                ((Pair) obj).second.equals(this.second));
    }

    /*
		Modificaci�n del m�todo 'copy' para copiar correctamente una instancia de Pair
    */
    @SuppressWarnings("unchecked")
    public Pair copy()  { return new Pair(first, second); }
}