"
I'm an example taken from SmalltalkReport's ""Just CloningAround"" article from Keith Piraino Volume 6 number 2 of October 96
"
Class {
	#name : 'DCCustomer',
	#superclass : 'Object',
	#instVars : [
		'invoices',
		'name'
	],
	#category : 'System-Model-Tests-Core',
	#package : 'System-Model-Tests',
	#tag : 'Core'
}

{ #category : 'initialization' }
DCCustomer >> initialize [ 
	super initialize.
	invoices := OrderedCollection new
]

{ #category : 'accessing' }
DCCustomer >> invoices [

	^ invoices
]

{ #category : 'accessing' }
DCCustomer >> invoices: anObject [

	invoices := anObject
]

{ #category : 'accessing' }
DCCustomer >> name [

	^ name
]

{ #category : 'accessing' }
DCCustomer >> name: anObject [

	name := anObject
]
