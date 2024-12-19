Extension { #name : 'OCAnnotationMarkNode' }

{ #category : '*OpalCompiler-Core' }
OCAnnotationMarkNode >> emitValue: methodBuilder [

	emitValueBlock ifNotNil: [ ^ emitValueBlock value: methodBuilder ].
	methodBuilder
		pushLiteralVariable: RuntimeSyntaxError binding;
		pushLiteral: 'Unhandled annotation';
		send: #signalSyntaxError:
]

{ #category : '*OpalCompiler-Core' }
OCAnnotationMarkNode >> emitValueBlock [

	^ emitValueBlock
]

{ #category : '*OpalCompiler-Core' }
OCAnnotationMarkNode >> emitValueBlock: anObject [

	emitValueBlock := anObject
]
