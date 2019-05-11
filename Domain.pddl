(define (domain Belkan-domain)
    (:requirements :strips :equality :typing)
    (:types orientacion
            zona
            humano objeto - locatable
            personaje jugador - humano
    )

    (:predicates
        (ori ?j - jugador ?o - orientacion )
        (at ?m - locatable ?x - zona)
        (conexion ?z1 - zona ?z2 - zona ?o - orientacion) ;conexion de z1 a z2 en direccion N
        (manovacia ?j - jugador)
        (manollena ?j - jugador ?obj - objeto)
        (tener ?p - personaje)
    )

    ;Giro izquierda
    (:action GIRAR-IZQ
      :parameters (?j - jugador ?o - orientacion)
      :precondition (ori ?j ?o)
      :effect (and
                (when (= ?o N) (and (not(ori ?j ?o)) (ori ?j W)))
                (when (= ?o E) (and (not(ori ?j ?o)) (ori ?j N)))
                (when (= ?o S) (and (not(ori ?j ?o)) (ori ?j E)))
                (when (= ?o W) (and (not(ori ?j ?o)) (ori ?j S)))
              )
    )

    ;Giro derecha
    (:action GIRAR-DCHA
      :parameters (?j - jugador ?o - orientacion)
      :precondition (ori ?j ?o)
      :effect (and
                (when (= ?o N) (and (not(ori ?j ?o)) (ori ?j E)))
                (when (= ?o E) (and (not(ori ?j ?o)) (ori ?j S)))
                (when (= ?o S) (and (not(ori ?j ?o)) (ori ?j W)))
                (when (= ?o W) (and (not(ori ?j ?o)) (ori ?j N)))
              )
    )

    ;Moverse a una zona
    (:action IR
      :parameters (?j - jugador ?o - orientacion ?z1 - zona ?z2 - zona)
      :precondition (and (ori ?j ?o) (at ?j ?z1) (conexion ?z1 ?z2 ?o))
      :effect (and (not (at ?j ?z1)) (at ?j ?z2))
    )

    ;Coger objeto
    (:action COGER
      :parameters (?j - jugador ?obj - objeto ?z - zona)
      :precondition (and (at ?j ?z) (at ?obj ?z) (manovacia ?j))
      :effect (and (not (manovacia ?j)) (manollena ?j ?obj) (not (at ?obj ?z)))
    )

    ;Dejar objeto en una zona
    (:action DEJAR
      :parameters (?j - jugador ?obj - objeto ?z - zona)
      :precondition (and (at ?j ?z) (manollena ?j ?obj))
      :effect (and (not (manollena ?j ?obj)) (manovacia ?j) (at ?obj ?z))
    )
    ;Entregar un objeto a un personaje
    (:action ENTREGAR
      :parameters (?j - jugador ?obj - objeto ?z - zona ?p - personaje)
      :precondition (and (at ?j ?z) (at ?p ?z) (manollena ?j ?obj))
      :effect(and (not (manollena ?j ?obj)) (manovacia ?j) (tener ?p))
    )

)
