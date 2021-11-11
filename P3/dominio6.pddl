; EJERCICIO 6
;
; Modificamos todos los elementos necesarios del dominio para que este
; sea capaz de usar información numérica
;
; 1.Crear acción 'Recolectar' para extraer recursos de un nodo y almacenarlos
; cada vez que se llame a la acción el número del material aumentará +10 pero tendra un limite de 60
;
; 2.Modificar acciones 'Construir' y 'Reclutar' para consumir una cantidad de recursos
; de los almacenados. A cada edificio/unidad se le asocia un coste de recursos
;
; 3.Modificar 'Asignar' para que cuente cuantas unidades hay extrayendo material
;
; 4.Añadimos funciones para gestionar la cantidad de recursos y su almacenamiento

(define (domain ejercicio_6)
	; Creamos 2 tipos generales que representan elementos del mundo(entidad)
	; como los edificios, unidades y localizaciones esto nos ayudará a
	; comprobar qué está en cada localización
	(:requirements :strips :adl :fluents)

	(:types
		; tenemos los tipos explicados
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
		Marine - tipoUnidad
		Segador - tipoUnidad

		CentroDeMando - tipoEdificio
		Barracones - tipoEdificio
		Extractor - tipoEdificio

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

		; Determinar si un edificio está construido
		(edificioConstruido ?edif - edificio)

		; Asignar un nodo de un recurso concreto a una localización concreta.
		(asignarNodoRecursoLocalizacion ?r - recurso ?x - localizacion)

		; Indicar si un VCE están extrayendo un recurso
		(estaExtrayendoRecurso ?uni - unidad ?rec - recurso)

		; He añadido este predicado para modelar el paso entre libre y extrayendo
		(unidadLibre ?uni - unidad)

		; Para saber de que subtipo es un edificio
		(esEdificio ?edif - edificio ?tipoEdif - tipoEdificio)

		; Para saber si hay recolectado un recurso
		(hayRecurso ?rec - tipoRecurso)

		; Predicado para comprobar de que tipo es la unidad
		(esUnidad ?unid - unidad ?tUnid - tipoUnidad)
	)

	; ## NUEVO ##
	; Funciones para modelar la cantidad de recursos
	(:functions
		(necesitaRecurso ?x - entidad ?rec - recurso)
		(recursoAlmacenado ?tipoRecurso - tipoRecurso )
		(topeRecurso ?tipoRecurso - tipoRecurso)
		(unidadesExtrayendo ?tipoRecurso - tipoRecurso ?loc - localizacion)
	)

	;Accion navegar: mueve a una unidad entre 2 localizaciones
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

			  ; La unidad tiene que estar libre(no extrayendo)(NO SIRVE DE NADA EN ESTE EJ)
			  (unidadLibre ?x)

			  ; Como ahora tenemos diferentes unidades tenemos que asegurarnos de que solo
			  ; las unidades tipo VCE puedan extraer recursos
			  (esUnidad ?x VCE)

			  ; Usamos una implicación: si el recurso a asignar es del tipo Mineral
			  ; se puede extraer directamente, si es del tipo Gas tiene que existir
			  ; un edificio tipo Extractor en la localizacion
			  (imply (asignarNodoRecursoLocalizacion Gas ?loc) (exists (?t - edificio) (and (esEdificio ?t Extractor) (entidadEnLocalizacion ?t ?loc) )))
		  )
	:effect
		  (and
			  ; Efectos
			  ; La unidad deja de estar libre
			  (not (unidadLibre ?x))
			  ; Un VCE esta extrayendo recurso
			  (estaExtrayendoRecurso ?x ?rec)

			  ; Se obtiene recurso
			  (hayRecurso ?rec)

			  ; ## NUEVO ##
			  ; Incrementamos en 1 el contador de unidades extrayendo el recurso
			  (increase
					(unidadesExtrayendo ?rec ?loc)
					1
			  )
		  )
	)

	; ## MODIFICADO ##

	; Accion construir: ordena a un VCE libre que construya un edificio en una localización
    ; Parámetros: Unidad, Edificio, Localizacion, Recurso
    (:action construir
 	 :parameters (?unidad - unidad ?edificio - edificio ?x - localizacion)
 	 :precondition
 		   (and
			   ; La unidad tiene que estar libre
			   (unidadLibre ?unidad)

			   ; Se comprueba que el edificio no esté ya construido
			   (not (edificioConstruido ?edificio))

			   ; La unidad tiene que estar en la localizacion a construir el edificio
			   (entidadEnLocalizacion ?unidad ?x)

			   ; Nos aseguramos que no hay otro edificio en esa localizacion
			   (not (exists (?edif - edificio) (entidadEnLocalizacion ?edif ?x)))

			   ; Para todos los posibles recursos necesarios en la construccion
			   (forall (?r - tipoRecurso)
				   ; Para un tipo de edificio en concreto
				   (exists (?t - tipoEdificio)
					   (and
						   ; Saber el tipo de edificio a construir
						   (esEdificio ?edificio ?t)

						    ; ## NUEVO ##
							; Tenemos una cantidad suficiente de recursos almacenados
							(>=
								(recursoAlmacenado ?r)
								(necesitaRecurso ?t ?r)
							)
						)
					)

				)
			)

	  :effect
	  		(and
				; Como efecto, se construye el edificio
 			    (entidadEnLocalizacion ?edificio ?x)

				; Se construye el edifio
				(edificioConstruido ?edificio)

				; ## NUEVO ##
				; Restamos los recursos usados al los almacenados

				; Si el edificio construido es Extractor restamos recursos utilizados para su construccion a cada recurso almacenado
				(when
					(esEdificio ?edificio Extractor)
					(and
						; Si necesitaba Mineral lo restamos
						(decrease
							(recursoAlmacenado Mineral)
							(necesitaRecurso Extractor Mineral)
						)
						; Si necesitaba Gas lo restamos
						(decrease
							(recursoAlmacenado Gas)
							(necesitaRecurso Extractor Gas)
						)
					)
				)
				; Si el edificio construido es Extractor restamos recursos utilizados para su construccion a cada recurso almacenado
				(when
					(esEdificio ?edificio Barracones)
					(and
						; Si necesitaba Mineral lo restamos
						(decrease
							(recursoAlmacenado Mineral)
							(necesitaRecurso Barracones Mineral)
						)
						; Si necesitaba Gas lo restamos
						(decrease
							(recursoAlmacenado Gas)
							(necesitaRecurso Barracones Gas)
						)
					)
				)
			)
	)

	; ## MODIFICADO ## 
	; Accion reclutar: recluta una nueva unidad que puede ser del tipo VCE,Marine o Segador
	; Parámetros: Edificio, Unidad, Localización
	(:action reclutar
		:parameters (?edificio - edificio ?unid - unidad  ?loc - localizacion)
		:precondition
			(and
				; Para reclutar(crear) una unidad no puede estar en ninguna localización
				; es importante recalcar que para crear unidades deberán instanciarse en el problema
				; para que posteriormente se puedan crear
				(not (exists (?l - localizacion) (and  (entidadEnLocalizacion ?unid ?l)) ) )

				; La acción reclutar solo se podrá llevar a cabo en Barracones o en Centros de mando
				; Esto evita un problema que me daba al interpretarse que se podía reclutar cualquier tipo
				; de unidad en los extractores
				(or (esEdificio ?edificio CentroDeMando) (esEdificio ?edificio Barracones))

				; ## NUEVO ##
				; Para cada recurso que se pueda necesitar para reclutar se comprueban las existenciaspara los tipos de recursos
				(forall (?r - tipoRecurso)
					(exists (?tUnid - tipoUnidad)
						(and
							; Saber el tipo de unidad a reclutar
 						    (esUnidad ?unid ?tUnid)
							(>=
								(recursoAlmacenado ?r)
								(necesitaRecurso ?tUnid ?r)
							)
						)
					)
				)



				; En la localización debe existir el edificio necesario
				(entidadEnLocalizacion ?edificio ?loc)

				; Si el edificio es centro de mando la unidad a reclutar tiene que ser VCE
				(imply (esEdificio ?edificio CentroDeMando) (esUnidad ?unid VCE))

				; Si el edificio es barracones la unidad a reclutar tiene que ser Marine o Segador
				(imply (esEdificio ?edificio Barracones) (or  (esUnidad ?unid Marine) (esUnidad ?unid Segador) ) )
			)

		:effect
			( and
				; Vinculamos la unidad a la localización actual e indicamos que está libre
				(entidadEnLocalizacion ?unid ?loc)
				(unidadLibre ?unid)

				; Si la unidad reclutada es VCE restamos recursos utilizados para su reclutamiento a cada recurso almacenado
				(when
					(esUnidad ?unid VCE)
					(and
						; Si necesitaba Mineral lo restamos
						(decrease
							(recursoAlmacenado Mineral)
							(necesitaRecurso VCE Mineral)
						)
						; Si necesitaba Gas lo restamos
						(decrease
							(recursoAlmacenado Gas)
							(necesitaRecurso VCE Gas)
						)
					)
				)

				; Si la unidad reclutada es Segador restamos recursos utilizados para su reclutamiento a cada recurso almacenado
				(when
					(esUnidad ?unid Segador)
					(and
						; Si necesitaba Mineral lo restamos
						(decrease
							(recursoAlmacenado Mineral)
							(necesitaRecurso Segador Mineral)
						)
						; Si necesitaba Gas lo restamos
						(decrease
							(recursoAlmacenado Gas)
							(necesitaRecurso Segador Gas)
						)
					)
				)

				; Si la unidad reclutada es Marine restamos recursos utilizados para su reclutamiento a cada recurso almacenado
				(when
					(esUnidad ?unid Marine)
					(and
						; Si necesitaba Mineral lo restamos
						(decrease
							(recursoAlmacenado Mineral)
							(necesitaRecurso Marine Mineral)
						)
						; Si necesitaba Gas lo restamos
						(decrease
							(recursoAlmacenado Gas)
							(necesitaRecurso Marine Gas)
						)
					)
				)
			)

	)


	; ## NUEVO ##
	; Accion recolectar: recolecta recursos de un nodo según el número de unidades extrayendo
	; cada vez que se llama a la acción incrementan las reservas de el recurso
	; Parámetros: Recurso Localización
	(:action recolectar
		:parameters (?rec - tipoRecurso ?loc - localizacion)
		:precondition
			(and
				; Se esta extrayendo el recurso a recolectar
				(hayRecurso ?rec)

				; Existe una unidad tal que
				;   -esa unidad está extrayendo el recurso
				; 	-existe un nodo del recurso en la localización
				; 	-la unidad está en la localización del nodo
				(exists (?unid - unidad)
					(and
						(estaExtrayendoRecurso ?unid ?rec)
						(asignarNodoRecursoLocalizacion ?rec ?loc)
						(entidadEnLocalizacion ?unid ?loc)
					)
				)


				; La suma de las existencias actuales y lo que se quiere sumar
				; no supera el tope de almacenamiento del recurso
				(<
					(+
						(recursoAlmacenado ?rec)
						(*
							10
							(unidadesExtrayendo ?rec ?loc)
						)
					)
					(topeRecurso ?rec)
				)
			)


		:effect
			(and
				; Incrementamos existencias de recurso 10 unidades por cada unidad extrayendo
				(increase
					(recursoAlmacenado ?rec)
					(*
						10
						(unidadesExtrayendo ?rec ?loc)
					)
				)
			)
	)

)
