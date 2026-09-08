Class {
	#name : 'CoBeginsWithBin',
	#superclass : 'CoResultBin',
	#category : 'HeuristicCompletion-Model-Core',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Core'
}

{ #category : 'testing' }
CoBeginsWithBin >> accepts: aCoGlobalEntry [ 

	^ aCoGlobalEntry contents beginsWith: resultSet filter completionString
]
