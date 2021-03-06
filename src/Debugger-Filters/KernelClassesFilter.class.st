"
A filter for kernel classes
"
Class {
	#name : #KernelClassesFilter,
	#superclass : #StackFilter,
	#instVars : [
		'kernelClasses'
	],
	#category : #'Debugger-Filters-Base'
}

{ #category : #initialization }
KernelClassesFilter >> initialize [
	
	super initialize.
	kernelClasses := self kernelClassesToExclude asOrderedCollection.
	kernelClasses := kernelClasses 
		addAll: (kernelClasses collect: [:each | each class]);
		yourself
	
]

{ #category : #private }
KernelClassesFilter >> kernelClassesToExclude [
	^ {Boolean.
	True.
	False.
	BlockClosure.
	Context.
	Array.
	OrderedCollection.
	Set.
	IdentitySet.
	Dictionary.
	IdentityDictionary.
	Class.
	Metaclass.
	Behavior.
	SmallInteger.
	Float.
	Error.
	Exception.
	UndefinedObject.
	MessageSend}
]

{ #category : #testing }
KernelClassesFilter >> shouldDisplay: aContext [
	"Clean blocks do not know the receiver, but they statically know the executed method 
	(which might be in a superclass)"
	^ aContext receiver 
		ifNil: [ 	(kernelClasses includes: aContext method methodClass) not ]
		ifNotNil: [ (kernelClasses includes: aContext receiver class) not ]
]
