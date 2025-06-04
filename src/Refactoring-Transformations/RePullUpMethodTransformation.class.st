"
I'm a transformation (no behavior preservation) that pull up a method to a superclass. 
I do not check that I'm changing the behavior of the program, or my siblings.
I only make sure that the instance variables and shared variable that the pulled up methods get pulled up too.
"
Class {
	#name : 'RePullUpMethodTransformation',
	#superclass : 'RBCompositeMethodTransformation',
	#instVars : [
		'selectors',
		'targetSuperclass'
	],
	#category : 'Refactoring-Transformations-Model-Migrated-Unused',
	#package : 'Refactoring-Transformations',
	#tag : 'Model-Migrated-Unused'
}

{ #category : 'api' }
RePullUpMethodTransformation class >> model: aRBNamespace pullUp: selectorCollection from: aClass [
	^ self new
		model: aRBNamespace;
		pullUp: selectorCollection from: aClass;
		yourself
]

{ #category : 'api' }
RePullUpMethodTransformation class >> model: aRBNamespace pullUp: selectorCollection from: aClass to: aSuperClass [
	^ self new
		model: aRBNamespace;
		pullUp: selectorCollection from: aClass to: aSuperClass;
		yourself
]

{ #category : 'api' }
RePullUpMethodTransformation class >> pullUp: selectorCollection from: aClass [
	^ self new pullUp: selectorCollection from: aClass
]

{ #category : 'api' }
RePullUpMethodTransformation class >> pullUp: selectorCollection from: aClass to: aSuperClass [
	^ self new pullUp: selectorCollection from: aClass to: aSuperClass
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> applicabilityPreconditions [

	^ {
		  (ReDefinesSelectorsCondition new
			   definesSelectors: selectors
			   in: class).
		  (ReClassHasSubclassesCondition new
			   class: targetSuperclass;
			   subclassesList: { class name }).
		self preconditionNoReferencesToSharedVars.
		}
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> buildTransformations [
	^ OrderedCollection new
		addAll: self pullUpVariables;
		addAll: self pullUpMethods;
		addAll: self removePulledUpMethods;
		addAll: self removeDuplicateMethods;
		yourself
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> checkClassVars [
	selectors do: [:each | self checkClassVarsFor: each]
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> checkClassVarsFor: aSelector [
	class instanceSide classVariableNames do:
		[ :each |
		((class whichSelectorsReferToClassVariable: each) includes: aSelector) ifTrue:
			[ self refactoringError: ('<1p> refers to <2s> which is defined in <3p>'
					expandMacrosWith: aSelector
					with: each
					with: class) ] ]
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> preconditionNoReferencesToInstVars [

	^ ReMethodsDontReferToInstVarsCondition new
		  class: class
		  selectors: selectors
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> preconditionNoReferencesToSharedVars [

	^ ReMethodsDontReferToLocalSharedVarsCondition new
		  class: class
		  selectors: selectors
]

{ #category : 'executing' }
RePullUpMethodTransformation >> pullUp: aSelector [
	| source refactoring |
	source := class sourceCodeFor: aSelector.
	source ifNil: [self refactoringError: 'Source for method not available'].
	refactoring := RBExpandReferencedPoolsTransformation
				model: self model
				forMethod: (class parseTreeForSelector: aSelector)
				fromClass: class
				toClasses: (Array with: targetSuperclass).
	^ Array
		with: refactoring
		with: (RBAddMethodTransformation
		model: self model
		sourceCode: source
		in: targetSuperclass
		withProtocol: (class protocolsFor: aSelector))
]

{ #category : 'api' }
RePullUpMethodTransformation >> pullUp: selectorCollection from: aClass [
	self pullUp: selectorCollection from: aClass to: aClass superclass
]

{ #category : 'api' }
RePullUpMethodTransformation >> pullUp: selectorCollection from: aClass to: aSuperClass [

	class := self model classObjectFor: aClass.
	targetSuperclass := self model classObjectFor: aSuperClass.
	selectors := selectorCollection.
	
]

{ #category : 'executing' }
RePullUpMethodTransformation >> pullUpMethods [
	^ selectors flatCollect: [:each | self pullUp: each]
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> pullUpVariable: aVariable [
	^ RBPullUpVariableTransformation
			model: self model
			instanceVariable: aVariable
			class: targetSuperclass
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> pullUpVariables [
	
	| pullUpVarTransform |
	pullUpVarTransform :=  OrderedCollection new.
	selectors do: [ :aSelector | 
		class instanceVariableNames do:
			[ :each |
				((class whichSelectorsReferToInstanceVariable: each) includes: aSelector) 
					ifTrue: [ pullUpVarTransform add: ( self pullUpVariable: each ) ] ] ].
	^ pullUpVarTransform 
]

{ #category : 'executing' }
RePullUpMethodTransformation >> removeDuplicateMethods [
	^ selectors collect: [:each | self removeDuplicatesOf: each]
]

{ #category : 'preconditions' }
RePullUpMethodTransformation >> removeDuplicatesOf: aSelector [

	^ RBCustomTransformation model: self model with: [ :rbModel |
			  | tree |
			  tree := targetSuperclass parseTreeForSelector: aSelector.
			  targetSuperclass allSubclasses collect: [ :aClass |
					  ((aClass directlyDefinesMethod: aSelector) and: [
							   (tree
								    equalTo: (aClass parseTreeForSelector: aSelector)
								    exceptForVariables: #(  )) and: [
									   (aClass superclass whichClassIncludesSelector: aSelector)
									   == targetSuperclass ] ]) ifTrue: [
							  
									  self generateChangesFor: (RBRemoveMethodTransformation
											   model: self model
											   selector: aClass
											   from: aSelector) ] ] ]
]

{ #category : 'executing' }
RePullUpMethodTransformation >> removePulledUpMethods [
	^ selectors collect: [:symbol |
		RBRemoveMethodTransformation
			model: self model
			selector: symbol
			from: class ]
]

{ #category : 'storing' }
RePullUpMethodTransformation >> storeOn: aStream [
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' pullUp: ';
		nextPutAll: selectors asString;
		nextPutAll: ' from: ';
		nextPutAll: class name;
		nextPutAll: ' to: ';
		nextPutAll: targetSuperclass name.
	aStream nextPut: $)
]
