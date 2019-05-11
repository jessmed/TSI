(define (problem Belkan-problem)

    (:domain Belkan-domain)

    (:objects z1 z2 z3 z4 z5 z6 z7 z8 z9 z10 z11 z12 z13 z14 z15 z16 z17 z18 z19 z20 z21 z22 z23 z24 z25 - zona
                N S W E - orientacion
                jugador1 - jugador
                oscar manzana rosa algoritmo oro - objeto
                princesa principe bruja profesor LeonardoDiCaprio - personaje
    )

    (:init
        (conexion z1 z6 S)
        (conexion z6 z1 N)
        (conexion z6 z7 E)
        (conexion z7 z6 W)
        (conexion z2 z7 S)
        (conexion z7 z2 N)
        (conexion z7 z8 E)
        (conexion z8 z7 W)
        (conexion z8 z9 E)
        (conexion z9 z8 W)
        (conexion z9 z14 S)
        (conexion z14 z9 N)
        (conexion z14 z13 W)
        (conexion z13 z14 E)
        (conexion z13 z12 W)
        (conexion z12 z13 E)
        (conexion z14 z19 S)
        (conexion z19 z14 N)
        (conexion z19 z18 W)
        (conexion z18 z19 E)
        (conexion z18 z17 W)
        (conexion z17 z18 W)
        (conexion z17 z16 W)
        (conexion z16 z17 E)
        (conexion z16 z11 N)
        (conexion z11 z16 S)
        (conexion z17 z22 S)
        (conexion z22 z17 N)
        (conexion z22 z21 W)
        (conexion z21 z22 E)
        (conexion z22 z23 E)
        (conexion z23 z22 W)
        (conexion z19 z20 E)
        (conexion z20 z19 W)
        (conexion z20 z25 S)
        (conexion z25 z20 N)
        (conexion z25 z24 W)
        (conexion z24 z25 E)
        (conexion z20 z15 N)
        (conexion z15 z20 S)
        (conexion z15 z10 N)
        (conexion z10 z15 S)
        (conexion z10 z5 N)
        (conexion z5 z10 S)
        (conexion z5 z4 W)
        (conexion z4 z5 E)
        (conexion z3 z4 E)
        (conexion z4 z3 W)




        (at jugador1 z1)
        (ori jugador1 S)

        ;Personajes
        (at bruja z2)
        (at profesor z12)
        (at principe z22)
        (at princesa z18)
        (at LeonardoDiCaprio z25)


        ;Objetos
        (at manzana z8)
        (at algoritmo z9)
        (at rosa z11)
        (at oro z15)
        (at oscar z5)

        (manoVacia jugador1)
    )

    (:goal (AND (tener bruja)
                (tener profesor)
                (tener LeonardoDiCaprio)
                (tener princesa)
                (tener principe))
    )
)
