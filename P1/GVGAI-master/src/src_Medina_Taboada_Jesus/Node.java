package src_Medina_Taboada_Jesus;
import core.game.StateObservation;
import ontology.Types;
import tools.Direction;
import tools.Vector2d;

import java.lang.reflect.Type;


/*
	Clase Node que sirve de unidad básica para implementar el comportamiento del agente,
	se utiliza en el algoritmo de búsqueda y para modelar la heurística principalmente.
*/
public class Node implements Comparable<Node> {

    public double totalCost;			// Coste total hasta el nodo
    public double estimatedCost;		// Estimación del coste hasta el nodo
    public Node parent;					// Nodo padre
    public Vector2d position;			// Posición del nodo
    public int id;						// Identificador del nodo
    public int orientation = -1;		// Orientación -1 como inicial

    /*
		Constructor del nodo que recibe la posicion como único argumento y que inicializa todos los atributos
		correctamente. El id se calcula en base a la posición.
    */
    public Node(Vector2d pos)
    {
        estimatedCost = 0.0f;
        totalCost = 1.0f;
        parent = null;
        position = pos;
        id = ((int)(position.x) * 100 + (int)(position.y));
    }

    /*
		Constructor a partir de un nodo dado como argumento, en este nuevo se copian correctamente todos los 
		atributos.
    */
    public Node(Node otro)
    {
        estimatedCost = otro.estimatedCost;
        totalCost = otro.totalCost;
        parent = null;
        position = new Vector2d( otro.position );
        orientation = otro.orientation;
        id = ((int)(position.x) * 100 + (int)(position.y));
    }

    /*
		Modificación del método 'compareTo' para comparar nodos. El criterio será comparar la suma
		del coste estimado y el coste total entre los dos nodos.
    */
    @Override
    public int compareTo(Node n) {
        if(this.estimatedCost + this.totalCost < n.estimatedCost + n.totalCost)
            return -1;
        if(this.estimatedCost + this.totalCost > n.estimatedCost + n.totalCost)
            return 1;
        return 0;
    }

    /*
		Modificación del método 'equals' para saber si dos nodos son iguales, tienen que cumplirse 2 condiciones,
		misma posición y misma orientación.
    */
    @Override
    public boolean equals(Object o)
    {
        return this.position.equals(((Node)o).position) && ((Node) o).orientation == this.orientation;
    }


    /*
		Método para determinar que acción se debe devolver o llevar a cabo entre 2 nodos.
		Hay 4 acciones posibles, ir a la derecha, a la izquierda, arriba o abajo.
		Recibe un nodo como argumento y comparando el atributo 'position.x'(para derecha e izquierda)
		o el atributo 'position.y' (para arriba y abajo) del nodo argumento con 
		la del nodo recibido se determina la acción correspondiente.
    */
    public Types.ACTIONS getMov(Node pre) {

        //TODO: New types of actions imply a change in this method.
        Types.ACTIONS action = Types.ACTIONS.ACTION_NIL;

        if(pre.position.x < this.position.x)
            action = Types.ACTIONS.ACTION_RIGHT;
        if(pre.position.x > this.position.x)
            action = Types.ACTIONS.ACTION_LEFT;

        if(pre.position.y < this.position.y)
            action = Types.ACTIONS.ACTION_DOWN;
        if(pre.position.y > this.position.y)
            action = Types.ACTIONS.ACTION_UP;

        return action;
    }
}
