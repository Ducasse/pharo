"
This is a particular englobing node that is a parentheses.
Exemple : ( parentheses node )
Can be created by forgetting 
either the opening : parentheses node )
or the closure : ( parentheses node .

"
Class {
	#name : #RBParenthesesErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes'
}

{ #category : #construction }
RBParenthesesErrorNode class >> error: aToken withNodes: aCollection [
	"Analyses the token to identify if it's an opening or a closure."
	| message |
	message := ('(' = aToken value asString) ifTrue: [ ''')'' expected' ] 
										  				 ifFalse: [ '''('' expected' ].
	"If the collection is empty, there is only the token in the error."
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: message ].
	"If the collection is not empty, we have to sort where the node begins and where it ends."
	^message = ''')'' expected'
		ifTrue: [ self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: message; createValue ]
		ifFalse: [ self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: message; createValue ]
]

{ #category : #testing }
RBParenthesesErrorNode >> isParenthesesError [
	^true
]

{ #category : #testing }
RBParenthesesErrorNode >> value [
	^  self errorMessage = '''('' expected' ifTrue: [ super value, ')' ] 
														ifFalse: [ '( ', super value ] 
]
