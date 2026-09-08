"
I am the main entry point of the completion system.
I am built from a (potentially composed) fetcher and a filter-string.

When asked for results, I fetch them from the fetcher.
Internally, I keep also a list of already fetched results to avoid fetching many times the same.
This is particularly useful when the filter is being narrowed (e.g., we go from a filter 'ab' to a filter 'abc').
In such a case, some of the results already fetched are still valid, and the fetcher state is valid too.
  => we then filter the subresults and change the fetcher filter
In case the filter is being broadened (e.g., we go from 'abc' to 'ab'), all results we already have are valid, but probably lots of other results were filtered already. So we reset both the results and the fetcher and restart the search.
"
Class {
	#name : 'CoBinnedResultSet',
	#superclass : 'Object',
	#instVars : [
		'results',
		'fetcher',
		'filter',
		'bins'
	],
	#classVars : [
		'SorterClass'
	],
	#category : 'HeuristicCompletion-Model-Core',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Core'
}

{ #category : 'instance creation' }
CoBinnedResultSet class >> fetcher: aFetcher [

	^ self new
		fetcher: aFetcher;
		yourself
]

{ #category : 'instance creation' }
CoBinnedResultSet class >> onContext: aCompletionContext fetcher: aFetcher [

	^ self new
		fetcher: aFetcher;
		yourself
]

{ #category : 'instance creation' }
CoBinnedResultSet class >> sorterClass [


	^ SorterClass
]

{ #category : 'instance creation' }
CoBinnedResultSet class >> sorterClass: aClass [
	"not sure that we will keep it. 
	For now we do not use it."
	SorterClass := aClass
]

{ #category : 'accessing' }
CoBinnedResultSet >> completionToken [

	^ filter completionString
]

{ #category : 'enumerating' }
CoBinnedResultSet >> ensureResults: aSize [

	self results size >= aSize ifTrue: [ ^ self ].
	self fetch: aSize - self results size
]

{ #category : 'fetching' }
CoBinnedResultSet >> fetch: requiredNumber [

	| fetched |	
	fetched := 0.
	[fetched < requiredNumber] whileTrue: [
		| newResult |
		newResult := fetcher next.
		newResult ifNil: [ ^ nil ].
		bins
			detect: [ :bin |
				bin accepts: newResult ]
			ifFound: [ :theBin | 
				theBin add: newResult.
				fetched := fetched + 1 ].
	]
]

{ #category : 'fetching' }
CoBinnedResultSet >> fetchAll [

	1halt.
	results addAll: fetcher upToEnd
]

{ #category : 'accessing' }
CoBinnedResultSet >> fetcher [
	^ fetcher
]

{ #category : 'accessing' }
CoBinnedResultSet >> fetcher: anObject [

	fetcher := anObject
]

{ #category : 'accessing' }
CoBinnedResultSet >> filter [

	^ filter
]

{ #category : 'accessing' }
CoBinnedResultSet >> filter: aFilter [

	filter := aFilter.
	"fetcher filter: filter"
]

{ #category : 'enumerating' }
CoBinnedResultSet >> first [

	self ensureResults: 1.
	^ self results first
]

{ #category : 'accessing' }
CoBinnedResultSet >> first: anInteger [

	self ensureResults: anInteger.

	self results size > anInteger
		ifTrue: [ ^ self results first: anInteger ].
	^ self results
]

{ #category : 'testing' }
CoBinnedResultSet >> hasMoreElements [

	^ fetcher atEnd not
]

{ #category : 'initialization' }
CoBinnedResultSet >> initialize [

	super initialize.
	filter := CoFilter empty.
	
	bins := OrderedCollection new.
	bins add: (CoBeginsWithBin on: self).
	bins add: (CoToleranceBin on: self)
]

{ #category : 'testing' }
CoBinnedResultSet >> notEmpty [

	^ self results notEmpty or: [ fetcher atEnd not ]
]

{ #category : 'api-filtering' }
CoBinnedResultSet >> replaceFilterWith: newFilter [

	"Narrow results"
	newFilter completionString = filter completionString ifTrue: [ ^ self ].

	newFilter completionString size >= filter completionString size
		ifTrue: [
			"Filter existing results"
			fetcher := fetcher narrowFilter: newFilter narrowKey: newFilter completionString ]
		ifFalse: [
			"Smaller filter, reset results and filter"
			fetcher := fetcher unnarrowFilter: newFilter narrowKey: newFilter completionString ].

	bins do: [ :bin | bin discardResults ].
	filter := newFilter
]

{ #category : 'api-filtering' }
CoBinnedResultSet >> resetFilter [

1halt.
	results removeAll.
	fetcher reset.
	fetcher filter: CoFilter empty
]

{ #category : 'accessing' }
CoBinnedResultSet >> results [

	^ bins flatCollect: [ :bin | bin results ]
]
