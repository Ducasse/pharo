"
I am a simple cache for AST nodes corresponding to CompiledMethods in the image. The cache is emptied when the image is saved.

The cached #ast is for one interesting for speed (that is, in situations where you ask for it often).

The other use-case is if you want to annotate the AST and keep that annotation around (till the next image save, but you can subscribe to ASTCacheReset and re-install the AST in the cache after cleaning. (This is used by MetaLinks to make sure they survive image restart).

The last thing that it provides is that we do have a quite powerful mapping between bytecode/text/context and the AST. Regardless of how you navigate, you get the same object.

e.g. even this one works:

    [ 1+2 ] sourceNode == thisContext method ast blockNodes first

**NOTE** due to the cached AST, Modification of the AST can be a problem.
Code that wants to modify the AST without making sure the compiledMethod is in sync later should use #parseTree. 

"
Class {
	#name : 'OCCache',
	#superclass : 'Object',
	#instVars : [
		'weakDictionary',
		'statistics'
	],
	#classVars : [
		'CacheMissStrategy'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AST-Core-Parser',
	#package : 'AST-Core',
	#tag : 'Parser'
}

{ #category : 'private - announcements' }
OCCache class >> announceCacheReset [

	self codeSupportAnnouncer announce: OCCacheReset new
]

{ #category : 'accessing' }
OCCache class >> at: aCompiledMethod [
	^ self default at: aCompiledMethod
]

{ #category : 'accessing' }
OCCache class >> cacheMissStrategy [
	^ CacheMissStrategy
		ifNil: [ CacheMissStrategy := OCCacheMissStrategy new ]
]

{ #category : 'accessing' }
OCCache class >> cacheMissStrategy: aCacheMissStrategy [
	^ CacheMissStrategy := aCacheMissStrategy
]

{ #category : 'accessing' }
OCCache class >> default [
	^ default ifNil: [
		SessionManager default registerSystemClassNamed: self name.
		default := self new ]
]

{ #category : 'accessing' }
OCCache class >> default: anASTCache [
	default := anASTCache
]

{ #category : 'class initialization' }
OCCache class >> reset [
	<script>
	self default reset.
	self announceCacheReset
]

{ #category : 'system startup' }
OCCache class >> shutDown [
	self reset
]

{ #category : 'adding' }
OCCache >> addHit [

	self statistics ifNotNil: [ statistics addHit ]
]

{ #category : 'adding' }
OCCache >> addMiss [

	self statistics ifNotNil: [ statistics addMiss ]
]

{ #category : 'accessing' }
OCCache >> at: aCompiledMethod [

	^ self
		  at: aCompiledMethod
		  ifAbsentPut: [ self getASTFor: aCompiledMethod ]
]

{ #category : 'accessing' }
OCCache >> at: aCompiledMethod ifAbsentPut: aBlock [
	"Get an AST using strongly held information, or failback to aBlock (that might compute a new AST)"

	"For doit methods, the AST is stored in the method property"

	(aCompiledMethod propertyAt: #ast) ifNotNil: [ :ast |
		self addHit.
		^ ast ].

	"Reflective methods have a strongly held AST, return this one"
	(aCompiledMethod propertyAt: #reflectiveMethod) ifNotNil: [ :rf |
		self addHit.
		^ rf ast ].

	"Look in the (almost infinite) cache"
	self weakDictionary at: aCompiledMethod ifPresent: [ :wa |
		(wa at: 1) ifNotNil: [ :ast |
			self addHit.
			^ ast ] ].

	"We tried everything we could. So compute and store it"
	self addMiss.
	^ self at: aCompiledMethod put: aBlock value
]

{ #category : 'accessing' }
OCCache >> at: aCompiledMethod put: aMethodNode [

	"Cleanup weak AST. Note `associations` return a copy, so the iteration is safe"
	| weakRef |
	self weakDictionary associations do: [ :each |
		(each value at: 1) ifNil: [
			self weakDictionary
				removeKey: each key
				ifAbsent: [ "prevent TOCTOU" ] ] ].

	weakRef := WeakArray new: 1.
	weakRef at: 1 put: aMethodNode.
	self weakDictionary at: aCompiledMethod put: weakRef.
	^ aMethodNode
]

{ #category : 'accessing' }
OCCache >> getASTFor: aCompiledMethod [

	^ self class cacheMissStrategy getASTFor: aCompiledMethod
]

{ #category : 'accessing - statistics' }
OCCache >> hitRatio [

	self statistics ifNil: [ ^ 0 ].
	^ self statistics hitRatio
]

{ #category : 'copying' }
OCCache >> postCopy [

	weakDictionary := weakDictionary copy.
	statistics := statistics copy
]

{ #category : 'printing' }
OCCache >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '#';
		print: self weakDictionary size;
		space;
		print: (self hitRatio * 100.0) rounded;
		nextPut: $%
]

{ #category : 'initialization' }
OCCache >> reset [
	self weakDictionary removeAll.
	weakDictionary := nil.
	statistics := nil.
]

{ #category : 'accessing' }
OCCache >> statistics [

	^ statistics ifNil: [ "CacheStatistics comes from another package. It does not worth the dependency"
		  self class environment at: #CacheStatistics ifPresent: [ :class | statistics := class new ] ]
]

{ #category : 'accessing' }
OCCache >> weakDictionary [

	^ weakDictionary ifNil: [
		  weakDictionary := WeakIdentityKeyDictionary new ]
]
