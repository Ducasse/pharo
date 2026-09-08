Class {
	#name : 'CoToleranceBin',
	#superclass : 'CoResultBin',
	#category : 'HeuristicCompletion-Model-Core',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Core'
}

{ #category : 'testing' }
CoToleranceBin >> accepts: anEntry [

	^ (self fuzzyScoreFor: anEntry contents) isZero not

]

{ #category : 'testing' }
CoToleranceBin >> damerauLevenshteinDistanceBetween: source and: target maxDistance: maxDistance [

	| previousRow currentRow twoRowsBack minInRow cost insertion deletion substitution value |
	source = target ifTrue: [ ^ 0 ].

	previousRow := Array new: target size + 1.
	1 to: (target size + 1) do: [ :j |
		previousRow at: j put: j - 1 ].

	1 to: source size do: [ :i |
		currentRow := Array new: target size + 1.
		currentRow at: 1 put: i.
		minInRow := i.

		1 to: target size do: [ :j |
			cost := ((source at: i) = (target at: j))
				ifTrue: [ 0 ]
				ifFalse: [ 1 ].

			insertion := (currentRow at: j) + 1.
			deletion := (previousRow at: (j + 1)) + 1.
			substitution := (previousRow at: j) + cost.

			value := insertion min: deletion.
			value := value min: substitution.

			(i > 1 and: [ j > 1 and: [
				(source at: i) = (target at: (j - 1))
					and: [ (source at: (i - 1)) = (target at: j) ] ] ]) ifTrue: [
						twoRowsBack ifNotNil: [
							value := value min: ((twoRowsBack at: (j - 1)) + 1) ] ].

			currentRow at: (j + 1) put: value.
			minInRow := minInRow min: value ].

		minInRow > maxDistance ifTrue: [ ^ 0 ].
		twoRowsBack := previousRow.
		previousRow := currentRow ].

	^ (previousRow last <= maxDistance)
		ifTrue: [ previousRow last ]
		ifFalse: [ 0 ]

]

{ #category : 'testing' }
CoToleranceBin >> fuzzyScoreFor: aString [

	^ self scoreForCandidate: aString
		token: self token
		caseSensitive: true
		tolerance: 0.1
]

{ #category : 'testing' }
CoToleranceBin >> scoreForCandidate: aCandidateString token: aTokenString caseSensitive: aBoolean tolerance: aTolerance [
	"Return zero if the candidate matches the token.
	
	"
	| candidate token maxSize maxEdits distance candidatePrefix|

	candidate := aCandidateString asString.
	token := aTokenString asString.
	
	token isEmpty ifTrue: [ ^ 0 ].
	candidate = token ifTrue: [ ^ 0 ].

	candidate := aBoolean
		ifTrue: [ candidate ]
		ifFalse: [ candidate asLowercase ]
		.
	token := aBoolean
		ifTrue: [ token ]
		ifFalse: [ token asLowercase ].

	(candidate beginsWith: token) ifTrue: [ ^ 0 ].
	(self shouldTryFuzzyFor: token candidate: candidate tolerance: aTolerance) ifFalse: [ ^ 0 ].

	maxSize := token size.
	maxEdits := (aTolerance * maxSize) floor .
	maxEdits <= 0 ifTrue: [ ^ 0 ].
	
	"Fuzzy matching is applied only to the first n characters of the candidate,
 	 where n = min(token size, candidate size).
 	 The untyped suffix of the candidate is irrelevant to edit distance."
	candidatePrefix := candidate copyFrom: 1 to: (token size min: candidate size).

	distance := self
		damerauLevenshteinDistanceBetween: token
		and: candidatePrefix
		maxDistance: maxEdits.

	distance ifNil: [ ^ 0 ].
	^ distance asFloat / maxSize
]

{ #category : 'testing' }
CoToleranceBin >> shouldTryFuzzyFor: token candidate: candidate tolerance: aTolerance [ 

	aTolerance <= 0.0 ifTrue: [ ^ false ].
	token isEmpty ifTrue: [ ^ false ].
	candidate isEmpty ifTrue: [ ^ false ].
	token size < 2 ifTrue: [ ^ false ].
	"2 is the minimum lentgh size"

	"Keep keyword arity stable"
	((token includes: $:) or: [ candidate includes: $: ]) ifTrue: [
		(token occurrencesOf: $:) = (candidate occurrencesOf: $:)
			ifFalse: [ ^ false ] ].
		
	^ true
]

{ #category : 'testing' }
CoToleranceBin >> token [ 

	^ resultSet filter completionString

]
