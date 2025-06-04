Class {
	#name : 'RBRenameClassRefactoringTest',
	#superclass : 'RBAbstractTransformationTest',
	#category : 'Refactoring-Transformations-Tests-Test',
	#package : 'Refactoring-Transformations-Tests',
	#tag : 'Test'
}

{ #category : 'failure tests' }
RBRenameClassRefactoringTest >> testFailureBadName [

	self shouldFail: (ReRenameClassRefactoring
			 rename: #RBLintRuleTestData
			 to: #TextConstants).
	self shouldFail:
		(ReRenameClassRefactoring rename: #RBLintRuleTestData to: #'Ob ject')
]

{ #category : 'failure tests' }
RBRenameClassRefactoringTest >> testFailureExistingName [

	self shouldFail:
		(ReRenameClassRefactoring rename: self class name to: #Object)
]

{ #category : 'failure tests' }
RBRenameClassRefactoringTest >> testFailureMetaClassFailure [

	self shouldFail:
		(ReRenameClassRefactoring rename: self class class name to: #Foo)
]

{ #category : 'tests' }
RBRenameClassRefactoringTest >> testModelRenameSequenceClass [

	model defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #ClassThatWillBeRenamed;
			package: #'Refactory-Test data' ].
	(model classNamed: #ClassThatWillBeRenamed)
		compile: 'foo	 ^ ClassThatWillBeRenamed' classified: #( accessing );
		compile: 'objectName ^ #(ClassThatWillBeRenamed)' classified: #( accessing ).


	(ReRenameClassRefactoring model: model rename: #ClassThatWillBeRenamed to: #NewClassName) generateChanges.
	(ReRenameClassRefactoring model: model rename: #NewClassName to: #FinalClassName) generateChanges.

	self deny: (model includesClassNamed: #ClassThatWillBeRenamed).
	self deny: (model includesClassNamed: #NewClassName).
	self assert: (model includesClassNamed: #FinalClassName).
	self 
		assert: ((model classNamed: #FinalClassName) parseTreeForSelector: #foo) 
		equals: (self parseMethod: 'foo ^ FinalClassName').
	self 
		assert: ((model classNamed: #FinalClassName) parseTreeForSelector: #objectName) 
		equals: (self parseMethod: 'objectName ^ #(FinalClassName)')
]

{ #category : 'tests' }
RBRenameClassRefactoringTest >> testRefactoring [

	| refactoring class |
	model defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #Foo;
			slots: { #a };
			package: #'Refactoring-Refactorings-Tests' ].

	class := model classNamed: #Foo.
	class
		compile: 'foo	^Object' classified: #( #accessing );
		compile: 'objectName ^#(Object)' classified: #( #accessing ).

	refactoring := ReRenameClassRefactoring model: model rename: #Object to: #Thing.

	refactoring generateChanges.

	self assert: (model includesClassNamed: #Thing).
	self deny: (model includesClassNamed: #Object).
	self assert: (class parseTreeForSelector: #foo) equals: (self parseMethod: 'foo ^Thing').
	self assert: (class parseTreeForSelector: #objectName) equals: (self parseMethod: 'objectName ^#(Thing)').
	self assert: class superclass name equals: #Thing
]

{ #category : 'tests' }
RBRenameClassRefactoringTest >> testRenameClass [
	| refactoring class classA classB classC aModel |

	classA := ('RBClass', 'ToRename') asSymbol.
	classB := ('RBNew', 'ClassName') asSymbol.
	classC := #RBSubclassOfClassToRename.

	refactoring := ReRenameClassRefactoring rename: classA to: classB.
	refactoring generateChanges.

	aModel := refactoring model.
	self assert: ((aModel classNamed: classB) parseTreeForSelector: #method1)
		  		equals: (self parseMethod: 'method1
	^self method2').
	self deny: (aModel includesClassNamed: classA).
	class := aModel classNamed: classC.
	self assert: class superclass equals: (aModel classNamed: classB).
	self assert: (class parseTreeForSelector: #symbolReference)
				equals: (self parseMethod: 'symbolReference
								^#RBNewClassName').
	self assert: (class parseTreeForSelector: #reference)
				equals: (self parseMethod: 'reference
								^RBNewClassName new')
]

{ #category : 'tests' }
RBRenameClassRefactoringTest >> testRenameClassFromTrait [
	| refactoring class classA classB classC aModel |

	classA := ('RBClass', 'ToRename') asSymbol.
	classB := ('RBNew', 'ClassName') asSymbol.
	classC := #RBTDummy.
	refactoring := ReRenameClassRefactoring rename: classA to: classB.
	refactoring generateChanges.
	aModel := refactoring model.
	self assert: (aModel includesClassNamed: classB).
	self deny: (aModel includesClassNamed: classA).
	class := aModel classNamed: classC.
	self assert: (class parseTreeForSelector: #methodFromTrait)
				equals: (self parseMethod: 'methodFromTrait
	RBNewClassName justForTest').
	self assert: ((refactoring model classNamed: #RBClassUsingSharedPoolForTestData) methodFor: #methodFromTrait) modelClass name equals: #RBTDummy
]

{ #category : 'tests' }
RBRenameClassRefactoringTest >> testUnmarkRemovedClassIfRenameTargetClass [
	"Unmark a removed class if we rename another class to the removed class name.
rename class A to C (class A is marked as removed)
rename class B to A
-> class A is not marked as removed (model includesClassNamed:#A -> true"

	| addClass renameClass classA classB classC |
	classA := ('RBClass' , 'ToRename') asSymbol.
	classB := 'TestUnmarkClassRenameSource' asSymbol.
	classC := 'TestUnmarkClassRenameTarget' asSymbol.
	addClass := (RBInsertNewClassTransformation model: model className: classB)
		            superclass: #Object;
		            packageName: self class package name;
		            yourself.
	addClass generateChanges.
	self assert: (model includesClassNamed: classA).
	renameClass := ReRenameClassRefactoring model: model rename: classA to: classC.
	renameClass generateChanges.
	self deny: (model includesClassNamed: classA).
	self assert: (model includesClassNamed: classC).
	renameClass := ReRenameClassRefactoring model: model rename: classB to: classA.
	renameClass generateChanges.
	self deny: (model includesClassNamed: classB).
	self assert: (model includesClassNamed: classC).
	self assert: (model includesClassNamed: classA)
]
