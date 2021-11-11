package src_Medina_Taboada_Jesus;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import tools.com.google.gson.internal.bind.ArrayTypeAdapter;


import java.lang.reflect.Array;
import java.lang.reflect.Type;
import java.util.*;

/*
 * Trabajo realizado por: Jesús Medina Taboada
 * Asignatura: Técnicas de los Sistemas Inteligentes
 * Curso: 2020-2021
 * 
 * 
 * 
 * NOTA IMPORTANTE: para poder usar los distintos comporatamientos del agente se debe ajustar la variable
 * 'gemas_a_obtener' que se encuentra en este archivo en el constructor de Agent.
 * 
 * 1. Deliberativo Simple: 'gemas_a_obtener' = 0  Para que el avatar busque directamente la salida y pueda salir
 * 												  pueda salir por ella.
 * 
 * 2. Deliberativo Compuesto: 'gemas_a_obtener'=0 Para que el avatar busque las gemas antes de salir por la salida
 * 
 * 3. Reactivo Simple:'gemas_a_obtener'=9		  Para que el avatar huya del enemigo y si pasa por encima del portal
 * 												  no pueda salir.
 * 4. Reactivo Compuesto:'gemas_a_obtener'=9      Para que el avatar huya del enemigo y si pasa por encima del portal
 * 												  no pueda salir.
 * 5. Reactivo Deliberativo:'gemas_a_obtener'=9   Para que el avatar huya del enemigo y busque las gemas y cuando tenga
 * 												  tenga las 9 pueda salir por la puerta.
*/



/*
	Clase principal de la práctica que determina cómo debe moverse el avatar de nuestro juego y que comportamiento
	seguirá según el mapa y el parámetro 'gema_a_obtener'.
*/
public class Agent extends AbstractPlayer{

    static final int ID_GEMA = 6;		// Identificador de gema
    Vector2d fescala; 					// Variable para hacer conversión de pixels a posicion en el grid(mapa)
    Vector2d portal;					// Identificación posición del portal
    Stack<Types.ACTIONS> plan;			// Plan que seguirá el avatar, es una pila de acciones
    int gemas_a_obtener;				// Gemas a obtener para poder salir por el portal
    int gemas_obtenidas;				// Gemas actuales obtenidas
    ArrayList<Observation> gemas;		// Array de posición de las gemas en el mapa
    Stack<Node> camino_gemas;			// Secuencia de nodos que hay que seguir para capturar las gemas
    									// es una pila de la clase Node
    
    boolean podemos_acabar;				// Variable que nos dice cuando podemos acabar y dirigirnos al portal



    // Variables para modelar el comportamiento reactivo del agente
    boolean hay_riesgo;
    boolean siempre_hay_riesgo;
    boolean me_he_movido_riesgo;
    Double[][] mapa_riesgo_base;
    Double[][] mapa_riesgo;
    

    /*
		Constructor del agente a partir del estado del juego del que extraeremos toda la información necesaria
		para calcular el comportamiento y el contador de tiempo para contar los ticks.
    */
    public Agent (StateObservation stateObs, ElapsedCpuTimer elapsedCpuTimer){
        gemas_a_obtener = 9;


        // Variable para realizar conversiones de escala de pixeles entre juego y mapa se divide fescala tendra
        // 2 valores para convertir ancho y alto
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);


        // IMPORTANTE!!!!!!! MODIFICAR AQUI VARIABLE gemas_obtenidas PARA CAMBIAR COMPORTAMIENTO DE AGENTE
        // Inicializamo variables básica del agente
        gemas_obtenidas = 9;
        plan = new Stack<>();
        hay_riesgo = false;
        me_he_movido_riesgo = true;
        podemos_acabar = false;
        gemas = new ArrayList<>();

        // Variable con el tamaño del mapa, ancho y alto
        Vector2d tam_mundo = new Vector2d (stateObs.getWorldDimension().width, stateObs.getWorldDimension().height);

        // Conversion del mapa de pixeles a posiciones de grid
        tam_mundo = pixelToGrid(tam_mundo);

        // Mapa que usaremos luego para el comportamiento deliberativo
        mapa_riesgo_base = new Double[(int)tam_mundo.x][(int)tam_mundo.y];



        // Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());

        
        // Establecemos la posición del portal
        
        // Si no hay portales
        if(posiciones == null ){
            portal = null;
        } else {
            // Si los hay seleccionamos el portal más próximo
            portal = posiciones[0].get(0).position;
            portal = pixelToGrid(portal);

            // Lista de gemas ordenadas por cercania al avatar
            ArrayList<Observation>[] gemas_array = stateObs.getResourcesPositions(stateObs.getAvatarPosition());

            // Si hay gemas en el mapa y hay suficientes gemas para que se cumpla la condición de salir
            // se entra al bloque, si no hay suficientes para salir, no.
            if (gemas_array != null && gemas_array[0].size() >= gemas_a_obtener){

            	// Iniciación de variables
                podemos_acabar = false;				// Condición de salida
                gemas = gemas_array[0];				// Número de gemas en el mapa
                camino_gemas = new Stack<>();		// Camino para recoger gemas
                gemas_obtenidas = 0;				// Gemas actuales obtenidas
                siempre_hay_riesgo = false;			// Riesgo por enemigos puesto a falso

                // Si tenemos muchas gemas, el calculo es muy grande, así que nos
                // quedamos con las 11 más prometedoras
                if (gemas.size() > 11){
                    List<Observation> gemas_2 = gemas.subList(0, 11);
                    gemas = new ArrayList<>(gemas_2);
                }

                // Calculamos el camino para obtener las gemas
                calcularCaminoGemas(stateObs, gemas_a_obtener);


            } else {
            	// Si las gemas a obtener son 0 no habrá enemigos en el mapa por lo que variable a true
                if (gemas_a_obtener != 0){
                    siempre_hay_riesgo = true;
                }
            }
        }


        // Inicializamos el riesgo, basicamente zonas de riesgo fijo (muros)
        inicializarRiesgo(stateObs);

    }


    /*
		Método init
    */
    public void init (StateObservation stateObs, ElapsedCpuTimer elapsedTimer){

    }

    /*
		Método que convierte una posición en pixeles del mundo a posiciones en el grid del mapa
		haciendo uso de la variable fescala
    */
    private Vector2d pixelToGrid( Vector2d pos){
        return  new Vector2d(pos.x / fescala.x, pos.y / fescala.y);
    }


    /*
		Modificación del método act cual calcula la siguiente acción que el avatar debe tomar desde un punto
		para lograr su objetivo, puede ser huir de enemigos obtener gemas o llegar al porta.
		El método devuelve una acción que puede ser derecha,izquierda,arriba,abajo o nil que es quedarse quieto.
    */
    @Override
    public Types.ACTIONS act (StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {

    	// La acción se inicializa en nil
        Types.ACTIONS accion = Types.ACTIONS.ACTION_NIL;

        // Calcula riesgo del mapa actual
        hay_riesgo = calcularRiesgo(stateObs);

        // Si hay algun riesgo se pasa a comportamiento reactivo de lo contrario se pasa a deliberativo
        if (hay_riesgo || siempre_hay_riesgo){
            // COMPORTAMIENTO REACTIVO
        	
        	// Obtenemos posición del avatar en posiciones del grid
            Vector2d pos = new Vector2d(pixelToGrid(stateObs.getAvatarPosition()));
            
            // Ponemos a true el riesgo de moverse
            me_he_movido_riesgo = true;

            // Calculamos una acción que iguale o disminuya el riesgo actual del mapa
            accion = calcularAccionRiesgo(stateObs);

            // Si ninguna acción es mejor que se accion devuelve nil y se inicializa la variable plan de nuevo
            if (accion != Types.ACTIONS.ACTION_NIL){
                plan = new Stack<>();
            }

        } else {
            // COMPORTAMIENTO DELIBERATIVO


            // El avatar se dirige al portal para salir
            if (portal != null){

            	// Comprueba que el numero de gemas del avatar coincide con el objetivo puesto
                if (stateObs.getAvatarResources().get(ID_GEMA) != null){
                    gemas_obtenidas = stateObs.getAvatarResources().get(ID_GEMA);
                }
                
                if (gemas_obtenidas >= gemas_a_obtener){
                    podemos_acabar = true;
                }

                // Aunque comprobemos dos veces lo mismo, no perdemos el tick para
                // calcular y otro para ejecutar, calculamos y ejecutamos en el mismo tick
                
                // Si podemos acabar y el plan está vacío se calcula el camino a seguir para llegar al portal
                // con el algoritmo A estrella
                if (podemos_acabar && plan.empty()){
                    calcularPlan(calcularPlanAStar(stateObs, pixelToGrid(stateObs.getAvatarPosition()),portal));

                  // Si no podemos acabar y el plan está vacio calcula plan
                } else if (plan.empty()){
                	
                	// Si quedan gemas y el camino de gemas no está vacio
                    if (!gemas.isEmpty() && !camino_gemas.isEmpty()){

                    	// Si habia riesgo lo desactivamos
                        if (me_he_movido_riesgo){
                            me_he_movido_riesgo = false;

                            // Con menos de 10 gemas somos capaz de recalcular en menos de 40ms
                            if (gemas_a_obtener - gemas_obtenidas < 6) {
                                gemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition())[0];
                                calcularCaminoGemas(stateObs, gemas_a_obtener - gemas_obtenidas);
                            }
                        // Si no habia riesgo saco gema y la quito del camino también
                        } else {
                            camino_gemas.pop();
                            gemas.remove(0);
                            
                        }
                        
                        calcularPlan(calcularPlanAStar(stateObs, pixelToGrid(stateObs.getAvatarPosition()), pixelToGrid(camino_gemas.peek().position) ));
                        
                    }

                }
                
                // Si plan no esta vacío y quedan ticks cogemos acción del plan y la guardamos en acion
                // luego sacamos esa acción del plan
                if (!plan.empty() && elapsedTimer.remainingTimeMillis() > 0){
                    accion = plan.peek();
                    plan.pop();

                }

            }

        }

        return accion;
    }

    /*
		Método que calcula el plan siguiendo el algoritmo A estrella, implementación del algoritmo
		igual, de forma que tenemos abiertos y cerrados(con priority queue) nodo fin y nodo destino.
		Usaremos la heuristica para estimar el ccoste estimado y posteriormente el coste total.
    */
    private Node calcularPlanAStar(StateObservation stateObs, Vector2d ini ,Vector2d dest){
        Node inicio = new Node(ini);
        inicio.orientation = orientacion(stateObs.getAvatarOrientation());

        Node fin = new Node(dest);

        PriorityQueue<Node> abiertos = new PriorityQueue<>();
        PriorityQueue<Node> cerrados = new PriorityQueue<>();

        // Fijamos coste de inicio a 0 porquen no nos cuesta nada llegar al inicio
        inicio.totalCost = 0;

        inicio.estimatedCost = heuristica(inicio, fin);

        // Añadimos primer nodo
        abiertos.add(inicio);

        // Inicializamos nodo solucion null y mejor de abiertos como inicio
        Node solucion = null;
        Node mejor_abiertos = inicio;

        boolean es_solucion = false;

        // Acciones disponibles
        ArrayList<Types.ACTIONS> actions = new ArrayList<>();
        actions.add(Types.ACTIONS.ACTION_RIGHT);
        actions.add(Types.ACTIONS.ACTION_LEFT);
        actions.add(Types.ACTIONS.ACTION_UP);
        actions.add(Types.ACTIONS.ACTION_DOWN);

        // Mientras abiertos no este vacio
        while (!abiertos.isEmpty() && !es_solucion){
            // Escogemos el mejor de abiertos (es una priority queue, ya
            // están ordenados)
            mejor_abiertos = abiertos.poll();
            cerrados.add(mejor_abiertos);

            fin.orientation = mejor_abiertos.orientation;
            es_solucion = mejor_abiertos.equals(fin);

            if (!es_solucion){

                // Expandimos el nodo aplicando las 4 acciones posibles
                for (Types.ACTIONS accion : actions){
                    Node hijo = new Node ( mejor_abiertos );

                    if (accion.equals(Types.ACTIONS.ACTION_LEFT) ){
                        hijo.position.x = hijo.position.x - 1;
                        hijo.orientation = 3;

                    } else if ( accion.equals(Types.ACTIONS.ACTION_RIGHT) ) {
                        hijo.position.x = hijo.position.x + 1;
                        hijo.orientation = 1;
                    } else if ( accion.equals(Types.ACTIONS.ACTION_UP) ) {
                        hijo.position.y = hijo.position.y - 1;
                        hijo.orientation = 0;

                    } else if ( accion.equals(Types.ACTIONS.ACTION_DOWN) ) {
                        hijo.position.y = hijo.position.y + 1;
                        hijo.orientation = 2;
                    }



                    if (!esObstaculo(stateObs, hijo)){

                        hijo.parent = mejor_abiertos;

                        hijo.totalCost = mejor_abiertos.totalCost + 1.0;

                        hijo.estimatedCost = heuristica(hijo, fin);

                        if (hijo.orientation != mejor_abiertos.orientation){
                            hijo.totalCost = hijo.totalCost + 1.0;
                        }


                        if (!abiertos.contains(hijo) && !cerrados.contains(hijo) ){
                            // Sumamos el coste desde el padre, más el hijo (1 de por sí, + 1 si tenía otra direccion)
                            // hijo.totalCost = mejor_abiertos.totalCost + hijo.totalCost;
                            abiertos.add(hijo);
                        } else {

                            if (abiertos.contains(hijo)){
                                ArrayList<Node> abiertos_array= new ArrayList<Node>(Arrays.asList(abiertos.toArray(new Node[abiertos.size()])));
                                Node ya_esta = abiertos_array.get(abiertos_array.indexOf(hijo));
                                if (ya_esta.totalCost > hijo.totalCost){
                                    abiertos.remove(ya_esta);
                                    abiertos.add(hijo);
                                }
                            }
                        }
                    }
                }
            } else {
                solucion = mejor_abiertos;
            }

        }
        if (solucion != null){
            return solucion;
        } else {
            Node mal = new Node(ini);
            mal.totalCost = -1.0;
            return mal;
        }

    }

    /*
    	Método que calcula la heurística(coste) usando el criterio de distancia manhattan
    	En nuestro problema la heurística es admisible y 1 tick es un movimiento
    */
    private double heuristica(Node inicio, Node fin){

        return( Math.abs(inicio.position.x - fin.position.x) +
                Math.abs(inicio.position.y - fin.position.y) );
    }


    /*
		Método que calcula el plan(stack de acciones) que seguirá el avatar para llegar
		al destino. Recordamos que en el plan se empieza metiendo el nodo destino y luego el parent
		de este, metiendo sucesivamente el nodo parent hasta llegar al punto donde estamos.
		De esta forma el top de la pila será la primera acción que debe realizar el avatar para llegar al
		destino y estarán de esta forma ordenadas.
    */
    private void calcularPlan(Node n){
        plan = new Stack<>();

        // Si n no es nula y no tiene parent nulo metemos en la pila el movimiento para llegar desde el parent
        // si orientación es diferente entre padre e hijo eliminamos acción de la pila para que no se guarden las
        // acciones nil
        while (n != null){

            if(n.parent != null) {

                plan.push(n.getMov(n.parent));

                if (n.orientation != n.parent.orientation){
                    plan.push(plan.peek());
                }

            }

            n = n.parent;
        }

    }
    
    /*
		Método que devuelve boolean para saber si un nodo es obstaculo o no
		toma de argumentos el estado del mundo y un nodo y comprueba si su posicion coincide
		con la de algun obstaculo
    */
    private boolean esObstaculo(StateObservation stateObs, Node nodo){
        ArrayList<Observation>[][] grid = stateObs.getObservationGrid();

        for(Observation obs : grid[(int)nodo.position.x][ (int)nodo.position.y]) {
            if(obs.itype == 0)
                return true;
        }


        return false;


    }

    /*
     Método para calcular orientación del avatar, he usado una orientación propia ya que la
     que venia por defecto me parecía mas complicada
    */
    
    private int orientacion(Vector2d o){
        // Si miramos hacia arriba o hacia abajo
        if (o.x == 0){
            // Si miramos hacia arriba en nuestro sistema es 0
            if (o.y == -1) {
                return 0;
            } else{
                // Hacia abajo es 2
                return 2;
            }
        } else {
            // Si estamos mirando hacia los lados
            if (o.x == -1){
                // En nuestro sistema mirar a la izquierda es 3
                return 3;
            } else {
                // Mirar a la derecha es 1
                return 1;
            }
        }
    }

    /*
		Método para calcular el camino para recolectar las gemas, va calculando el camino óptimo(por el total cost)
		a cada gema y cuando llega a una calcula el camino a la siguiente hasta que se elabora un camino para
		recoger todas las gemas disponibles(luego no se recogeran todas).
		
    */
    private void calcularCaminoGemas(StateObservation stateObs, int num_gem){

    	// Matriz para coste de las gemas
        Double[][] distancias = new Double[gemas.size() + 2][gemas.size() + 2];

        // Calculo coste para alcanzar cada gema
        for (int i = 0; i < gemas.size(); i++){
            for (int j = i; j < gemas.size(); j++){
                distancias[i][j] = calcularPlanAStar(stateObs, pixelToGrid(gemas.get(i).position), pixelToGrid(gemas.get(j).position) ).totalCost;
                distancias[j][i] = distancias[i][j];
            }
            distancias[i][i] = 0.0;

        }


        for (int i = 0; i < gemas.size(); i++){

            distancias[gemas.size()][i] = calcularPlanAStar(stateObs, pixelToGrid(gemas.get(i).position), portal ).totalCost;
            distancias[i][gemas.size()] = distancias[gemas.size()][i];


            distancias[gemas.size()+1][i] = calcularPlanAStar(stateObs, pixelToGrid(stateObs.getAvatarPosition()), pixelToGrid(gemas.get(i).position) ).totalCost;
            distancias[i][gemas.size()+1] = distancias[gemas.size()+1][i];
        }

        // No hace falta calcular de la posicion inicial al portal, esa nunca la usaremos

        distancias[gemas.size()][gemas.size()] = 0.0;
        distancias[gemas.size()+1][gemas.size()+1] = 0.0;

        // Priority queue para almacenar caminos posibles
        PriorityQueue<Pair<ArrayList<Integer>, Double>> caminos = new PriorityQueue<>();
        

        for (int i = 0; i < gemas.size(); i++){
            ArrayList<Integer> ini = new ArrayList<>();
            ini.add(i);
            caminos.add(new Pair<>(ini, distancias[gemas.size()+1][i]));
        }


        boolean he_encontrado_mejor = false;
        Pair<ArrayList<Integer>, Double> mejor = caminos.peek() ;


        do {

            mejor = caminos.poll();

            if (mejor == null){
                System.out.println("Esto nunca debería pasar, el mapa está mal");
                System.out.println("Deberia tener al menos 10 gemas accesibles");
                he_encontrado_mejor = true;
            } else if (mejor.first.size() >= num_gem){
                // He_encontrado_mejor = true;
                // Si tenemos 11, ya esta el portal
                if (mejor.first.size() >= num_gem + 1){
                    he_encontrado_mejor = true;
                } else {
                    ArrayList<Integer> n_camino = new ArrayList<>(mejor.first);
                    n_camino.add(gemas.size());
                    caminos.add(new Pair<>(n_camino, mejor.second + distancias[gemas.size()][n_camino.get(n_camino.size() - 2)]));
                }
            } else {
                for (int i = 0; i < gemas.size(); i++){
                    if (!mejor.first.contains(i) && distancias[i][mejor.first.get(mejor.first.size()-1)] != -1){
                        ArrayList<Integer> n_camino = new ArrayList<>(mejor.first);
                        n_camino.add(i);
                        caminos.add(new Pair<>(n_camino, mejor.second + distancias[i][n_camino.get(n_camino.size() - 2)] ));
                    }
                }
            }

        } while(!he_encontrado_mejor);


        camino_gemas = new Stack<>();
        if (mejor != null) {
            mejor.first.remove(mejor.first.size() - 1);
            for (int i = mejor.first.size() - 1; i >= 0; i--) {
                Node nuevo = new Node(gemas.get(mejor.first.get(i)).position);
                camino_gemas.add(nuevo);
            }
        }

    }


    /*
		Método para calcular riesgos del mapa, de vuelve true si la posición actual es un riesgo
    */
    private boolean calcularRiesgo(StateObservation stateObs){
        // Obtenemos posicion de NPCs
    	ArrayList<Observation>[] NPC = stateObs.getNPCPositions();

        // Inicializamos valores básicos, en general riesgo 0, muros riesgo infinito
        Vector2d tam_mundo = new Vector2d (stateObs.getWorldDimension().width, stateObs.getWorldDimension().height);

        tam_mundo = pixelToGrid(tam_mundo);

        mapa_riesgo = new Double[(int)tam_mundo.x][(int)tam_mundo.y];
        for (int i = 0; i < mapa_riesgo_base.length; i++){
            for (int j = 0; j < mapa_riesgo_base[i].length; j++){
                mapa_riesgo[i][j] = mapa_riesgo_base[i][j];
            }
        }
        // Añadimos riesgo a los muros

        if (NPC != null){
            ArrayList<Observation> enemigos = NPC[0];

            for (Observation enemigo : enemigos){
                Vector2d posicion = new Vector2d(pixelToGrid(new Vector2d(enemigo.position)));

                for (int k = 5; k >= -5; k--){
                    for (int l = 5; l >= -5; l--){
                        int x = (int)posicion.x + k;
                        int y = (int)posicion.y + l;
                        if (0 <= x && x < mapa_riesgo.length && 0 <= y && y < mapa_riesgo[x].length){
                            if ( !mapa_riesgo[x][y].equals(Double.MAX_VALUE) && !esObstaculo(stateObs, new Node( new Vector2d(x,y) ) ) ){
                                

                                if ( Math.abs(l) < 2 && Math.abs(k) < 2){
                                    if (mapa_riesgo[x][y] < 35.0)
                                        mapa_riesgo[x][y] = 35.0;
                                } else if ( Math.abs(l) < 3 && Math.abs(k) < 3){
                                    if (mapa_riesgo[x][y] < 30.0)
                                        mapa_riesgo[x][y] = 30.0;
                                } else if (Math.abs(l) < 4 && Math.abs(k) < 4) {
                                    if (mapa_riesgo[x][y] < 25.0)
                                        mapa_riesgo[x][y] = 25.0;
                                } if (Math.abs(l) < 5 && Math.abs(k) < 5) {
                                    if (mapa_riesgo[x][y] < 20.0)
                                        mapa_riesgo[x][y] = 20.0;
                                } else {
                                    if (mapa_riesgo[x][y] < 17.0)
                                        mapa_riesgo[x][y] = 17.0;
                                }


                            }

                        }

                    }
                }

                mapa_riesgo[(int)posicion.x][(int)posicion.y] = Double.MAX_VALUE;


            }
        }


        // Intentamos ir a por las gemas, quitando riesgo al rededor de estas
        ArrayList<Observation>[] GEM = stateObs.getResourcesPositions();
        if (GEM != null){
            ArrayList<Observation> gemas_por_recoger = GEM[0];

            for (Observation gema : gemas_por_recoger){
                Vector2d posicion = new Vector2d(pixelToGrid(new Vector2d(gema.position)));

                for (int k = 3; k >= -3; k--){
                    for (int l = 3; l >= -3; l--){
                        int x = (int)posicion.x + k;
                        int y = (int)posicion.y + l;
                        if (0 <= x && x < mapa_riesgo.length && 0 <= y && y < mapa_riesgo[x].length){
                            if ( !mapa_riesgo[x][y].equals(Double.MAX_VALUE) && !esObstaculo(stateObs, new Node( new Vector2d(x,y) ) ) ){
                                
                                if ( Math.abs(l) < 2 && Math.abs(k) < 2){
                                    mapa_riesgo[x][y] -= 7.0;
                                } else if ( Math.abs(l) < 3 && Math.abs(k) < 3){
                                    mapa_riesgo[x][y] -= 6.0;
                                } else {
                                    mapa_riesgo[x][y] -= 5.0;
                                }

                            }

                        }

                    }
                }



            }
        }


        Vector2d pos_personaje = new Vector2d(pixelToGrid(stateObs.getAvatarPosition()) ) ;

        // 16.0 es el mayor riesgo que pueden generar los muros.
        return mapa_riesgo[(int)pos_personaje.x][(int)pos_personaje.y] > 16.0;

    }

    /*
		Método para inicializar riesgos
    */
    private void inicializarRiesgo(StateObservation stateObs){

        // Ponemos el mapa vacio
        for (int i = 0; i < mapa_riesgo_base.length; i++) {
            for (int j = 0; j < mapa_riesgo_base[i].length; j++) {
                mapa_riesgo_base[i][j] = 0.0;
            }
        }
        
        
        ArrayList<Observation>[] w = stateObs.getImmovablePositions();

        if (w != null){
            ArrayList<Observation> muros = w[0];

            // para todos los muros
            for (Observation muro : muros){
                Vector2d posicion = new Vector2d(pixelToGrid(new Vector2d(muro.position)));

                for (int k = 2; k >= -2; k--){
                    for (int l = 2; l >= -2; l--){
                        int x = (int)posicion.x + k;
                        int y = (int)posicion.y + l;
                        if (0 <= x && x < mapa_riesgo_base.length && 0 <= y && y < mapa_riesgo_base[x].length){
                            if ( !esObstaculo(stateObs, new Node( new Vector2d(x,y) ) ) ){
                                //int suma = Math.abs(k) + Math.abs(l);
                                if ( Math.abs(l) < 2 && Math.abs(k) < 2){
                                    mapa_riesgo_base[x][y] += 1.0;
                                } else {
                                    mapa_riesgo_base[x][y] += 0.5;
                                }

                            }

                        }

                    }
                }

                mapa_riesgo_base[(int)posicion.x][(int)posicion.y] = Double.MAX_VALUE;

            }

        }

        if (siempre_hay_riesgo){
            int xcentro = mapa_riesgo_base.length/2;
            int ycentro = mapa_riesgo_base[0].length/2;

            for (int i = -xcentro; i < xcentro; i++){
                for (int j = -ycentro; j < ycentro; j++){
                    int x = xcentro + i;
                    int y = ycentro + j;

                    if (0 <= x && x < mapa_riesgo_base.length && 0 <= y && y < mapa_riesgo_base[x].length){
                        if ( !esObstaculo(stateObs, new Node( new Vector2d(x,y) ) ) ){
                     
                            int distancia = Math.max(Math.abs(i), Math.abs(j));
                            mapa_riesgo_base[x][y] -= 5.0/distancia;

                        }

                    }
                }
            }
        }



    }


    /*
		Método para calcular la acción que reduzca o al menos no aumente el siegos acctual
		de la posición del avatar.
		Toma posición,orientación y reisgo actual del avatar y compara con el riesgo si efectuamos
		una de las acciones posibles. Si encontramos una acción que disminuya el riesgo se escoge
		y se actualiza el riesgo, al comprobar todas las acciones posibles nos quedaremos con la mejor.
    */
    private Types.ACTIONS calcularAccionRiesgo(StateObservation stateObs) {

        Types.ACTIONS accion = Types.ACTIONS.ACTION_NIL;

        Node pos = new Node(pixelToGrid(stateObs.getAvatarPosition()));
        pos.orientation = orientacion(stateObs.getAvatarOrientation());

        Double riesgo_actual = mapa_riesgo[(int)pos.position.x][(int)pos.position.y];

        if (mapa_riesgo[(int)pos.position.x + 1][(int)pos.position.y] <= riesgo_actual){
            accion = Types.ACTIONS.ACTION_RIGHT;
            riesgo_actual = mapa_riesgo[(int)pos.position.x + 1][(int)pos.position.y];
        }

        if (mapa_riesgo[(int)pos.position.x - 1][(int)pos.position.y] <= riesgo_actual){
            accion = Types.ACTIONS.ACTION_LEFT;
            riesgo_actual = mapa_riesgo[(int)pos.position.x - 1][(int)pos.position.y];
        }

        if (mapa_riesgo[(int)pos.position.x][(int)pos.position.y - 1] <= riesgo_actual){
            accion = Types.ACTIONS.ACTION_UP;
            riesgo_actual = mapa_riesgo[(int)pos.position.x][(int)pos.position.y - 1];

        }

        if (mapa_riesgo[(int)pos.position.x][(int)pos.position.y + 1] <= riesgo_actual){
            accion = Types.ACTIONS.ACTION_DOWN;
        }

        return accion;

    }

}