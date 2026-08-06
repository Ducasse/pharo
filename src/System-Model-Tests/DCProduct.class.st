"
I'm an example taken from SmalltalkReport's ""Just CloningAround"" article from Keith Piraino Volume 6 number 2 of October 96
"
Class {
	#name : 'DCProduct',
	#superclass : 'Object',
	#instVars : [
		'name',
		'unitPrice'
	],
	#category : 'System-Model-Tests-Core',
	#package : 'System-Model-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
DCProduct >> name [

	^ name
]

{ #category : 'accessing' }
DCProduct >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
DCProduct >> unitPrice [

	^ unitPrice
]

{ #category : 'accessing' }
DCProduct >> unitPrice: anObject [

	unitPrice := anObject
]
