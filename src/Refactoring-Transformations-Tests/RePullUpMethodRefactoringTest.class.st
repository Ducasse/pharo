Class {
	#name : 'RePullUpMethodRefactoringTest',
	#superclass : 'RBAbstractRefactoringTest',
	#category : 'Refactoring-Transformations-Tests-Test',
	#package : 'Refactoring-Transformations-Tests',
	#tag : 'Test'
}

{ #category : 'tests' }
RePullUpMethodRefactoringTest >> addClassHierarchyForPools [

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

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> addClassHierarchyWithSlots [

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
RePullUpMethodRefactoringTest >> testFailurePullUpWithSuperSendThatCannotBeCopiedDown [

	| class |
	self addClassHierarchy.
	(model classNamed: #Object)
		compile: 'foo ^3'
		classified: #( #accessing ).
		
	(model classNamed: #Subclass)
		compile: 'foo ^super foo'
		classified: #( #accessing ).
		
	(class := model classNamed: #Foo2)
		compile: 'foo ^1'
		classified: #( #accessing ).

	self shouldFail:
		(RePullUpMethodRefactoring model: model pullUp: #( #foo ) from: class)
]

{ #category : 'tests' }
RePullUpMethodRefactoringTest >> testPullUpAndCopyDown [

	| class refactoring |
	self addClassHierarchy.
	class := model classNamed: #Foo1.
	class compile: 'yourself ^1' classified: #(#accessing).
	
	self proceedThroughWarning: [
		refactoring := RePullUpMethodRefactoring model: model pullUp: #( #yourself) from: class.
		refactoring execute ].
	
	self 
		assert: (class superclass parseTreeForSelector: #yourself)
		equals: (self parseMethod: 'yourself ^1').
	
	self deny: (class directlyDefinesMethod: #yourself).
	
	class := model classNamed: #Foo2.
	
	self assert: (class directlyDefinesMethod: #yourself).
	self 
		assert: (class parseTreeForSelector: #yourself)
		equals: ((model classNamed: #Object) parseTreeForSelector: #yourself)
]

{ #category : 'tests' }
RePullUpMethodRefactoringTest >> testPullUpInAHighHierarchyClass [
	| siblingClass1 root superclassOfSibling |

	self addClassHierarchy.
	siblingClass1 := model classNamed: #Foo1.

	root := model classNamed: #SomeClass.
	siblingClass1 compile: 'example ^1' classified: #(#accessing).
	self executeRefactoring: (RePullUpMethodRefactoring
				model: model
				pullUp: #(#example)
				from: siblingClass1
				to: root ).
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
RePullUpMethodRefactoringTest >> testPullUpMethodWithCopyOverriddenMethodsDown [
	| refactoring |
	self proceedThroughWarning:
		[ refactoring := RePullUpMethodRefactoring pullUp:  #(#isComposite ) from: RBCompositeLintRuleTestData.
		self executeRefactoring: refactoring ].
	
	self 
		assert: ((refactoring model classNamed: #RBBasicLintRuleTestData)
			parseTreeForSelector: #isComposite)
		equals: (self parseMethod: 'isComposite ^false').
	self 
		assert: ((refactoring model classNamed: ('RBFoo' , 'LintRuleTestData') asSymbol)
			parseTreeForSelector: #isComposite)
		equals: (self parseMethod: 'isComposite ^false').
	self 
		assert: ((refactoring model classNamed: #RBLintRuleTestData)
			parseTreeForSelector: #isComposite)
		equals: (self parseMethod: 'isComposite ^true').
	self deny: ((refactoring model classNamed: #RBCompositeLintRuleTestData)
		directlyDefinesMethod: #isComposite)
]

{ #category : 'tests' }
RePullUpMethodRefactoringTest >> testPullUpMethodWithSharedPool [
	| class superClass |

	self addClassHierarchyForPools.
	class := model classNamed: #Toto.
	superClass := model classNamed: #TotoSuperclass.
	self proceedThroughWarning: [
		self executeRefactoring: (RePullUpMethodRefactoring
			model: model
			pullUp: #(#poolReference)
			from: class
			to: superClass) ].

	self 
		assert: (superClass parseTreeForSelector: #poolReference)
		equals: (self parseMethod: 'poolReference ^ SP').
		
	self deny: (class directlyDefinesMethod: #poolReference)
]

{ #category : 'tests' }
RePullUpMethodRefactoringTest >> testPullUpWithConflictingSiblingsInstanceVariable [

	| refactoring class superClass otherSibling |
	self skip.
	self flag: #rtodo. 
	"when we work on https://github.com/pharo-project/pharo/issues/18248 this test should be changed and it should pass."
	self addClassHierarchyWithSlots.
	class := model classNamed: #SubSubRootSibling1.
	class compile: 'foo ^ sameAsInSibling' classified: 'whatever'.
		
	self proceedThroughWarning: [
		self executeRefactoring:  (RePullUpMethodRefactoring model: model pullUp: #( #foo ) from: class).].	
	
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

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> testPullUpWithReferencesInstVariablePushesSharedVariableToo [

	| refactoring class superClass |
	class := model classNamed: ('RBTransformation', 'RuleTestData1') asSymbol.
	refactoring := RePullUpMethodRefactoring  model: model pullUp:  #(#foo ) from: class.
	self proceedThroughWarning: [ refactoring generateChanges ].
	superClass := model classNamed: ('RBFooLint', 'RuleTestData1') asSymbol.
	self 
		assert: (superClass parseTreeForSelector: #foo)
		equals: (self parseMethod: 'foo ^ foo').
	self deny: (class directlyDefinesMethod: #foo).
	
	self assert: (class directlyDefinesInstanceVariable: #foo)
]

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> testPullUpWithReferencesInstVariablePushesVariableToo [

	| refactoring class superClass |
	class := model classNamed: ('RBTransformation', 'RuleTestData1') asSymbol.
	refactoring := RePullUpMethodRefactoring  model: model pullUp:  #(#foo ) from: class.
	self proceedThroughWarning: [ refactoring generateChanges ].
	superClass := model classNamed: ('RBFooLint', 'RuleTestData1') asSymbol.
	self 
		assert: (superClass parseTreeForSelector: #foo)
		equals: (self parseMethod: 'foo ^ foo').
	self deny: (class directlyDefinesMethod: #foo).
	
	self assert: (class directlyDefinesInstanceVariable: #foo)
]

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> testWarnDoesntPullUpReferencesInstVar [

	| refactoring class |
	class := model classNamed:
		         ('RBTransformation' , 'RuleTestData1') asSymbol.
	refactoring := RePullUpMethodRefactoring
		               model: model
		               pullUp: #( #foo )
		               from: class.
	self shouldWarn: refactoring
]

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> testWarnPullUpWithInvalidSuperSend [

	| class |
	self addClassHierarchy.
	(model classNamed: #Foo2)
		compile: 'yourself ^super yourself + 1'
		classified: #( #accessing ).
	class := model classNamed: #Foo1.
	class compile: 'yourself ^1' classified: #( #accessing ).

	self shouldWarn:
		(RePullUpMethodRefactoring model: model pullUp: { #yourself } from: class)
]

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> testWarnWhenPullUpWillOverrideMethodFromSuperclass [

	model defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #SomeClass;
			sharedVariables: { #Foo };
			package: #'Refactory-Test data' ].
	(model classNamed: #SomeClass) compile: 'yourself ^54' classified: #( #accessing ).

	self shouldWarn: (RePullUpMethodRefactoring model: model pullUp: #( #yourself ) from: (model classNamed: #SomeClass))
]

{ #category : 'failure tests' }
RePullUpMethodRefactoringTest >> testWarnWhenPulledMethodRefersToLocalSharedVar [

	| class |
	class := model classNamed: #Object.
	class addClassVariable: #Foo.
	class classSide compile: 'foo ^Foo' classified: #( #accessing ).
	self shouldWarn:
		(RePullUpMethodRefactoring model: model pullUp:  #( #foo ) from: class classSide)
]
