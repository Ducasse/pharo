"
I'm an example taken from SmalltalkReport's ""Just CloningAround"" article from Keith Piraino Volume 6 number 2 of October 96
"
Class {
	#name : 'DCOrderedItem',
	#superclass : 'Object',
	#instVars : [
		'quote',
		'quantity',
		'product'
	],
	#category : 'System-Model-Tests-Core',
	#package : 'System-Model-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
DCOrderedItem >> product [

	^ product
]

{ #category : 'accessing' }
DCOrderedItem >> product: anObject [

	product := anObject
]

{ #category : 'accessing' }
DCOrderedItem >> quantity [

	^ quantity
]

{ #category : 'accessing' }
DCOrderedItem >> quantity: anObject [

	quantity := anObject
]

{ #category : 'accessing' }
DCOrderedItem >> quote [

	^ quote
]

{ #category : 'accessing' }
DCOrderedItem >> quote: anObject [

	quote := anObject
]
