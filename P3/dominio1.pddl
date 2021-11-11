(define (domain ejercicio_1)
	; Declaramos los requisitos del dominio
	(:requirements :strips :adl :fluents)

	(:types
		; Creamos 2 tipos generales que representan elementos del mundo(entidad)
		; como los edificios, unidades y localizaciones esto nos ayudará a
		; comprobar qué está en cada localización
		entidad localizacion - object

		; Las unidades recursos y edificios son de tipo entidad
		unidad - entidad
		edificio - entidad
		recurso - object

		; Tipos derivados de los anteriores
		tipoEdificio - edificio
		tipoUnidad - unidad
		tipoRecurso - recurso
	)

	; Declaramos constantes para representar los tipos de unidad, tipos de
	; edificio y los tipos de recursos
	(:constants
		VCE - tipoUnidad
		CentroDeMando - tipoEdificio
		Barracones - tipoEdificio
		Mineral - tipoRecurso
		Gas - tipoRecurso
	)

	; Definimos los predicados necesarios
	(:predicates

		; Determinar si un edificio o unidad (entidad)
		; está en una localización concreta
		(entidadEnLocalizacion ?obj - entidad ?x - localizacion)

		; Representar que existe un camino entre 2 localizaciones
		; como nuestro mapa es cuadricular sin diagonales lo representaremos
		; como la relación entre 2 localizaciones
		(caminoEntre ?x1 - localizacion ?x2 - localizacion)

		; Determinar si un edificio está construido(NO LO USAMOS)
		(edificioConstruido ?edif - edificio)

		; Asignar un nodo de un recurso concreto a una localización concreta.
		(asignarNodoRecursoLocalizacion ?r - recurso ?x - localizacion)

		; Indicar si un VCE están extrayendo un recurso
		(estaExtrayendoRecurso ?uni - unidad ?rec - recurso)

		; PREDICADOS EXTRA

		; He añadido este predicado para modelar el paso entre libre y extrayendo
		(unidadLibre ?uni - unidad)

	)

	; Accion navegar: mueve a una unidad entre 2 localizaciones
	; Parámetros: Unidad, Localización origen(x) localizacion destino(y)
	(:action navegar
	  :parameters (?unidad - unidad ?x ?y - localizacion)
	  :precondition
	  		(and
				; Precondiciones:
				; La unidad tiene que estar en localización origen
				(entidadEnLocalizacion ?unidad ?x)
				; Las localizaciones tienen que estar conectadas
				(caminoEntre ?x ?y)
				; La unidad tiene que estar libre (no extrayendo recursos)
				(unidadLibre ?unidad)
			)

	  :effect
	  		(and
				; Efectos:
				; La unidad pasa a la localización destino
				(entidadEnLocalizacion ?unidad ?y)
				; La unidad deja de estar en la localización origen
				(not (entidadEnLocalizacion ?unidad ?x))
			)
	)

	; Accion asignar: asigna un VCE a un nodo de recurso
	; Parámetros: Unidad, Localización del recurso, Tipo recurso
	(:action asignar
	  :parameters (?x - unidad ?loc - localizacion ?rec - recurso)
	  :precondition
	  		(and
				; Precondiciones:
				; La unidad tiene que estar en la localizacion
				(entidadEnLocalizacion ?x ?loc)

				; En la localización tiene que estar el recurso de ese tipo
				(asignarNodoRecursoLocalizacion ?rec ?loc)

				; La unidad tiene que estar libre(no extrayendo)
				(unidadLibre ?x)
			)
	  :effect
	  		(and
				; Efectos
				; La unidad deja de estar libre
				(not (unidadLibre ?x))
				; Un VCE esta extrayendo recurso
				(estaExtrayendoRecurso ?x ?rec)
			)
	)
)
