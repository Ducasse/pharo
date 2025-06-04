Class {
	#name : 'RePullUpMethodTransformationTest',
	#superclass : 'RBAbstractTransformationTest',
	#category : 'Refactoring-Transformations-Tests-Test',
	#package : 'Refactoring-Transformations-Tests',
	#tag : 'Test'
}

{ #category : 'tests' }
RePullUpMethodTransformationTest >> addClassHierarchy [

	model
		defineClass: [ :aBuilder |
			aBuilder
				superclass: Object;
				name: #SomeClass;
				sharedVariables: { #Foo };
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #SomeClass;
				name: #Subclass;
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #Subclass;
				name: #Foo1;
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #Subclass;
				name: #Foo2;
				package: #'Refactory-Test data' ]
]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> addClassHierarchyForPools [

	model
		defineClass: [ :aBuilder |
			aBuilder
				superclass: SharedPool;
				name: #TotoSharedPool;
				sharedVariables: { #SP };
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclass: Object;
				name: #TotoSuperclass;
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #TotoSuperclass;
				name: #Toto;
				sharedPools: #(TotoSharedPool);
				package: #'Refactory-Test data' ].

	(model classNamed: #Toto) 
		compile: 'poolReference ^ SP' 
		classified: #( #accessing )
]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> addClassHierarchyWithSlots [

	model
		defineClass: [ :aBuilder |
			aBuilder
				superclass: Object;
				name: #Root123;
				sharedVariables: { #RootSharedVariable1 };
				slots: { #rootSlot };
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #Root123;
				name: #SubRoot123;
				slots: { #rootSubSlot };
				sharedVariables: { #RootSubSharedVariable1 };
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #SubRoot123;
				name: #SubSubRootSibling1;
				slots: { #sameAsInSibling . #uniqueSubSubRootSibling1 };
				package: #'Refactory-Test data' ];
		defineClass: [ :aBuilder |
			aBuilder
				superclassName: #SubRoot123;
				slots: { #sameAsInSibling . #uniqueSubSubRootSibling2 };
				name: #SubSubRootSibling2;
				package: #'Refactory-Test data' ]
]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> testPullUpInAHighHierarchyClass [
	| siblingClass1 root superclassOfSibling refactoring |

	self addClassHierarchy.
	siblingClass1 := model classNamed: #Foo1.

	root := model classNamed: #SomeClass.
	siblingClass1 compile: 'example ^1' classified: #(#accessing).
	refactoring :=  (RePullUpMethodTransformation
				model: model
				pullUp: #(#example)
				from: siblingClass1
				to: root ).
	refactoring generateChanges.
	self 
		assert: (root parseTreeForSelector: #example)
		equals: (self parseMethod: 'example ^1').
		
	self deny: (siblingClass1 directlyDefinesMethod: #example).

	superclassOfSibling := model classNamed: #Subclass.
	self assert: (superclassOfSibling definesMethod: #example).
	self 
		assert: (superclassOfSibling parseTreeForSelector: #example)
		equals: ((model classNamed: #SomeClass) parseTreeForSelector: #example)
]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> testPullUpMethodWithSharedPool [
	| class superClass refactoring |

	self addClassHierarchyForPools.
	class := model classNamed: #Toto.
	superClass := model classNamed: #TotoSuperclass.
	refactoring := (RePullUpMethodTransformation
			model: model
			pullUp: #(#poolReference)
			from: class
			to: superClass).
	refactoring generateChanges.

	self 
		assert: (superClass parseTreeForSelector: #poolReference)
		equals: (self parseMethod: 'poolReference ^ SP').
		
	self deny: (class directlyDefinesMethod: #poolReference)
]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> testPullUpWithConflictingSiblingsInstanceVariable [

	| refactoring class superClass otherSibling |
	self addClassHierarchyWithSlots.
	class := model classNamed: #SubSubRootSibling1.
	class compile: 'foo ^ sameAsInSibling' classified: 'whatever'.
	
	refactoring := RePullUpMethodTransformation model: model pullUp: #( #foo ) from: class.
		
	refactoring  generateChanges.
	
	superClass := model classNamed: #SubRoot123.
	
	self 
		assert: (superClass parseTreeForSelector: #foo)
		equals: (self parseMethod: 'foo ^ sameAsInSibling').
	
	self deny: (class directlyDefinesMethod: #foo).
	"automatically the used instance variable is moved up"
	self assert: (superClass directlyDefinesInstanceVariable: #sameAsInSibling).
	
	otherSibling := model classNamed: #SubSubRootSibling2.
	
	self deny: (otherSibling directlyDefinesInstanceVariable: #sameAsInSibling).




]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> testPullUpWithReferencesInstVariablePushesVariableToo [

	| refactoring class superClass otherSibling |
	class := model classNamed: ('RBTransformation', 'RuleTestData1') asSymbol.
	refactoring := RePullUpMethodTransformation model: model pullUp: #( #foo ) from: class.
		
	refactoring  generateChanges.
	
	superClass := model classNamed: ('RBFooLint', 'RuleTestData1') asSymbol.
	self 
		assert: (superClass parseTreeForSelector: #foo)
		equals: (self parseMethod: 'foo ^ foo').
	self deny: (class directlyDefinesMethod: #foo).
	"automatically the used instance variable is moved up"
	self assert: (superClass directlyDefinesInstanceVariable: #foo)
]

{ #category : 'tests' }
RePullUpMethodTransformationTest >> testTransformationDoesNotCareOfSuperSendThatCannotBeCopiedDown [

	| class refactoring |
	self addClassHierarchyWithSlots.
	(model classNamed: #Object)
		compile: 'foo ^3'
		classified: #( #accessing ).
		
	(model classNamed: #SubRoot123)
		compile: 'foo ^super foo'
		classified: #( #accessing ).
		
	(class := model classNamed: #SubSubRootSibling1 )
		compile: 'foo ^1'
		classified: #( #accessing ).

	refactoring := RePullUpMethodTransformation model: model pullUp: #(foo) from: class.
	refactoring generateChanges.
	"self assert: class" 
	
	"Yes the pullUp did not pay attention and the superclass method was not copied down either."
	
	self 
		assert: ((model classNamed: #SubRoot123) parseTreeForSelector: #foo)
		equals: (self parseMethod: 'foo ^1').
		
	self 
		deny: ((model classNamed: #SubSubRootSibling1) directlyDefinesMethod: #foo).
	self 
		deny: ((model classNamed: #SubSubRootSibling2) directlyDefinesMethod: #foo).
	
]
