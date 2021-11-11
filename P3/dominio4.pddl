; EJERCICIO 4
;
; 1.Crear acción 'Reclutar' para crear nuevas unidades 'Marine' y 'Segador'
;
; 2.La creación de cada unidad necesita recursos distintos y se crean en edificios distintos
;	VCEs -> mineral -> (CENTRO DE MANDO)
;   Marines -> mineral -> (BARRACONES)
;   Segadores -> mineral y gas vespeno -> (BARRACONES)

(define (domain ejercicio_4)
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
		; ### NUEVOS ###
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

		; ## NUEVO MODIFICACIÓN ##
		; Cambiamos a un predicado más genérico donde se indica que recursos
		; necesita una entidad ya que ahora las unidades también necesitan recursos
		(necesitaRecurso ?x - entidad ?rec - tipoRecurso)

		; Para saber de que subtipo es un edificio
		(esEdificio ?edif - edificio ?tipoEdif - tipoEdificio)

		; Para saber si hay recolectado un recurso
		(hayRecurso ?rec - tipoRecurso)

		; ### NUEVO ###
		; Predicado para comprobar de que tipo es la unidad
		(esUnidad ?unid - unidad ?tUnid - tipoUnidad)
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

			   ; ## NUEVO ##
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
		   )
   )

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
						   ; Necesitamos estar extrayendo los recursos necesarios para la construccion
						   (imply (necesitaRecurso ?t ?r) (hayRecurso ?r) )
					   )
				   )
			   )
		   )

	 :effect
		   (and
			   ; Se construye el edifio
			   (edificioConstruido ?edificio)
			   ; Como efecto, se construye el edificio
			   (entidadEnLocalizacion ?edificio ?x)
		   )
   )

	; ### NUEVO ###
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

				; Para reclutar VCEs o Marines necesitamos minerales
				(imply (or (esUnidad ?unid VCE) (esUnidad ?unid Marine) ) (hayRecurso Mineral))

				; Para reclutar Segadores necesitamos mineral y gas
				(imply (esUnidad ?unid Segador) (and (hayRecurso Mineral) (hayRecurso Gas)) )

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
			)

	)
)
