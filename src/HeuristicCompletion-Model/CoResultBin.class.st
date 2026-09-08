Class {
	#name : 'CoResultBin',
	#superclass : 'Object',
	#instVars : [
		'resultSet',
		'results'
	],
	#category : 'HeuristicCompletion-Model',
	#package : 'HeuristicCompletion-Model'
}

{ #category : 'instance creation' }
CoResultBin class >> on: aCoBinnedResultSet [ 
	
	^ self new
		resultSet: aCoBinnedResultSet;
		yourself
]

{ #category : 'testing' }
CoResultBin >> accepts: anEntry [

	^ false
]

{ #category : 'adding' }
CoResultBin >> add: aCoGlobalEntry [ 
	
	results add: aCoGlobalEntry
]

{ #category : 'as yet unclassified' }
CoResultBin >> discardResults [
	
	results removeAll
]

{ #category : 'initialization' }
CoResultBin >> initialize [

	super initialize.
	results := OrderedCollection new
]

{ #category : 'accessing' }
CoResultBin >> resultSet: aCoBinnedResultSet [ 
	resultSet := aCoBinnedResultSet
]

{ #category : 'accessing' }
CoResultBin >> results [
	^ results
]
