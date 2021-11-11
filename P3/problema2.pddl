(define (problem ejercicio2)

	(:domain ejercicio_2)

	(:objects
		; Mapa 3x4
		l1_1 l1_2 l1_3 l1_4 l2_1 l2_2 l2_3 l2_4 l3_1 l3_2 l3_3 l3_4 - localizacion
		; Unidades, edificios y recursos
		VCE1 VCE2 - unidad
		CentroDeMando1 Extractor1 - edificio
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

		; Posicionamos el edificio, los VCE y decimos que están libres
		(entidadEnLocalizacion CentroDeMando1 l1_1)
		(entidadEnLocalizacion VCE1 l1_1)
		(entidadEnLocalizacion VCE2 l1_1)
		(unidadLibre VCE1)
		(unidadLibre VCE2)

		; Indicamos que el centro de mando 1 está construido
		(edificioConstruido CentroDeMando1)
		
		;  La construcción de los extractores requiere minerales
		(necesitaRecurso Extractor Mineral)

		; Establecemos los tipos de edificios
		(esEdificio CentroDeMando1 CentroDeMando)
		(esEdificio Extractor1 Extractor)

		; Sitiamos los 2 recursos de mineral y 1 de gas
		(asignarNodoRecursoLocalizacion Mineral l2_3)
		(asignarNodoRecursoLocalizacion Mineral l3_3)
		(asignarNodoRecursoLocalizacion Gas l1_3)

	)

	(:goal
		(and
			; OBJETIVO: generar recursos de tipo gas vespeno
			(hayRecurso Gas)
		)
	)
)
