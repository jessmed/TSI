(define (problem ejercicio6)

	(:domain ejercicio_6)

	(:objects
		; Mapa 3x4
		l1_1 l1_2 l1_3 l1_4 l2_1 l2_2 l2_3 l2_4 l3_1 l3_2 l3_3 l3_4 - localizacion
		; Unidades, edificios y recursos
		VCE1 VCE2 VCE3 - unidad
		Marine1 Marine2 Segador1 - unidad
		CentroDeMando1 Barracones1 Extractor1 - edificio
	)

	(:init
		; Conexiones del mapa 3x4
		(caminoEntre l1_1 l1_2)
		(caminoEntre l1_2 l1_1)
		(caminoEntre l1_1 l2_1)
		(caminoEntre l2_1 l1_1)
		(caminoEntre l1_2 l2_2)
		(caminoEntre l2_2 l1_2)
		(caminoEntre l2_1 l3_1)
		(caminoEntre l3_1 l2_1)
		(caminoEntre l3_1 l3_2)
		(caminoEntre l3_2 l3_1)
		(caminoEntre l3_2 l2_2)
		(caminoEntre l2_2 l3_2)
		(caminoEntre l2_2 l2_3)
		(caminoEntre l2_3 l2_2)
		(caminoEntre l2_3 l1_3)
		(caminoEntre l1_3 l2_3)
		(caminoEntre l1_3 l1_4)
		(caminoEntre l1_4 l1_3)
		(caminoEntre l1_4 l2_4)
		(caminoEntre l2_4 l1_4)
		(caminoEntre l2_4 l3_4)
		(caminoEntre l3_4 l2_4)
		(caminoEntre l3_3 l3_4)
		(caminoEntre l3_4 l3_3)

		; Al principio solo habrá un VCE disponible y el centro de mandos
		(entidadEnLocalizacion CentroDeMando1 l1_1)
		(entidadEnLocalizacion VCE1 l1_1)
		(unidadLibre VCE1)

		; Establecemos los tipos de edificios
		(esEdificio CentroDeMando1 CentroDeMando)
		(esEdificio Extractor1 Extractor)
		(esEdificio Barracones1 Barracones)

		; Establecemos que tipo de unidad es cada una
		(esUnidad VCE1 VCE)
		(esUnidad VCE2 VCE)
		(esUnidad VCE3 VCE)

		(esUnidad Marine1 Marine)
		(esUnidad Marine2 Marine)
		(esUnidad Segador1 Segador)

		; Sitiamos los 2 recursos de mineral y 1 de gas
		(asignarNodoRecursoLocalizacion Mineral l2_3)
		(asignarNodoRecursoLocalizacion Mineral l3_3)
		(asignarNodoRecursoLocalizacion Gas l1_3)

		; ## NUEVO ##
		; Establecemos la cantidad de recursos que necesita cada edificio y/o unidades

		; Edificios
		(= (necesitaRecurso Barracones Mineral) 50)
		(= (necesitaRecurso Barracones Gas) 20)
		(= (necesitaRecurso Extractor Mineral) 33)
		(= (necesitaRecurso Extractor Gas) 0)

		; Unidades
		(= (necesitaRecurso VCE Mineral) 10)
		(= (necesitaRecurso VCE Gas) 0)
		(= (necesitaRecurso Marine Mineral) 20)
		(= (necesitaRecurso Marine Gas) 10)
		(= (necesitaRecurso Segador Mineral) 30)
		(= (necesitaRecurso Segador Gas) 30)


		; Establecemos los recursos iniciales a 0 y los topes de cantidad que podemos almacenar
		(= (recursoAlmacenado Gas) 0)
		(= (recursoAlmacenado Mineral) 0)
		(= (topeRecurso Gas) 60)
		(= (topeRecurso Mineral) 60)

		; Contador de unidades VCE destinadas a cada recurso
		(= (unidadesExtrayendo Mineral l2_3) 0)
		(= (unidadesExtrayendo Mineral l3_3) 0)
		(= (unidadesExtrayendo Gas l1_3) 0)
	)

	(:goal
		(and
			; El objetivo es disponer de 2 marines, uno en 3_1 y otro en 2_4.
			; También necesitamos tener un segador en la localización 1_2
			; aparte de los objetivos anteriores como tener construido barracones en 3_2
			(entidadEnLocalizacion Barracones1 l3_2)
			(edificioConstruido Barracones1)
			(entidadEnLocalizacion marine1 l3_1)
			(entidadEnLocalizacion marine2 l2_4)
			(entidadEnLocalizacion segador1 l1_2)
		)
	)
)
