(list
 (cons 'batchSwarm
       (make-instance 'BatchSwarm
                      #:displayFrequency 1
		      #:maxEvolutions 5000000))
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
			#:numberOfRules 240
			#:turnoverRate  0.75F0
			#:crossoverRate 0.75F0
			#:mutationRate  0.002F0
			#:evolutionFrequency 1.0F0
			#:childrenFitness 0.0F0
			#:useDeltaFitness 1.0F0
		  
		      )
       )
 )

