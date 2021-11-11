(define (problem ejercicio1)

	(:domain ejercicio_1)

	(:objects
		; Mapa 3x4
		l1_1 l1_2 l1_3 l1_4 l2_1 l2_2 l2_3 l2_4 l3_1 l3_2 l3_3 l3_4 - localizacion
		; Unidades, edificios y recursos
		VCE1 - unidad
		CentroDeMando1 - edificio
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


		; Posicionamos el edificio, el VCE y decimos que está libre
		(entidadEnLocalizacion CentroDeMando1 l1_1)
		(entidadEnLocalizacion VCE1 l1_1)
		(unidadLibre VCE1)

		; Sitiamos los 2 recursos de mineral
		(asignarNodoRecursoLocalizacion Mineral l2_3)
		(asignarNodoRecursoLocalizacion Mineral l3_3)

	)

	(:goal
		(and
			; OBJETIVO: generar recursos de tipo mineral
			(estaExtrayendoRecurso VCE1 Mineral)
		)
	)
)
