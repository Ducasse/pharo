"
I'm an example taken from SmalltalkReport's ""Just CloningAround"" article from Keith Piraino Volume 6 number 2 of October 96
"
Class {
	#name : 'DCInvoice',
	#superclass : 'Object',
	#instVars : [
		'customer',
		'orderedItems',
		'salesPerson'
	],
	#category : 'System-Model-Tests-Core',
	#package : 'System-Model-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
DCInvoice >> customer [

	^ customer
]

{ #category : 'accessing' }
DCInvoice >> customer: anObject [

	customer := anObject
]

{ #category : 'accessing' }
DCInvoice >> orderedItems [

	^ orderedItems
]

{ #category : 'accessing' }
DCInvoice >> orderedItems: anObject [

	orderedItems := anObject
]

{ #category : 'accessing' }
DCInvoice >> salesPerson [

	^ salesPerson
]

{ #category : 'accessing' }
DCInvoice >> salesPerson: anObject [

	salesPerson := anObject
]
