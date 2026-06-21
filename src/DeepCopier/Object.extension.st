Extension { #name : 'Object' }

{ #category : '*DeepCopier' }
Object >> veryDeepCopy [
	"Do a complete tree copy using a dictionary.  An object in the tree twice is only copied once.  All references to the object in the copy of the tree will point to the new copy."

	| copier new |
	copier := DeepCopier new initialize: 4096 "self initialDeepCopierSize".
	new := self veryDeepCopyWith: copier.
	copier references associationsDo: [:assoc |
		assoc value veryDeepFixupWith: copier].
	copier fixDependents.
	^ new
]

{ #category : '*DeepCopier' }
Object >> veryDeepCopyWith: deepCopier [
	"Copy me and the entire tree of objects I point to.  An object in the tree twice is copied once, and both references point to him.  deepCopier holds a dictionary of objects we have seen.  Some classes refuse to be copied.  Some classes are picky about which fields get deep copied."

	| class selfNumberOfInstanceVariables fieldOfSelf copyOfSelf currentClass hasVeryDeepInnerMethod currentNumberOfInstanceVariables |

	deepCopier references at: self ifPresent: [ :newer | 	"already copied" ^ newer].
	class := self class.
	class isMeta ifTrue: [ "a metaclass" ^ self ].
	copyOfSelf := self shallowCopy.
	deepCopier references at: self put: copyOfSelf.	"remember"

	(class isVariable and: [class isPointers]) ifTrue: [
		self basicSize to: 1 by: -1 do: [ :i |
			fieldOfSelf := self basicAt: i.
			copyOfSelf
				basicAt: i
				put: (deepCopier references
					at: fieldOfSelf
					ifAbsent: [ fieldOfSelf veryDeepCopyWith: deepCopier ])]].

	"Ask each superclass if it wants to share (weak copy) any inst vars"
	copyOfSelf veryDeepInner: deepCopier.

	"other superclasses want all instance variables deep copied"
	currentClass := class.
	selfNumberOfInstanceVariables := class instSize.

	[ selfNumberOfInstanceVariables == 0 ] whileFalse: [
		hasVeryDeepInnerMethod := currentClass includesSelector: #veryDeepInner:.
		currentNumberOfInstanceVariables := currentClass instSize - currentClass superclass instSize.
		hasVeryDeepInnerMethod
			ifTrue: ["skip inst vars"
				selfNumberOfInstanceVariables := selfNumberOfInstanceVariables - currentNumberOfInstanceVariables]
			ifFalse: [
				currentNumberOfInstanceVariables timesRepeat: [
					fieldOfSelf := self instVarAt: selfNumberOfInstanceVariables.
					copyOfSelf
						instVarAt: selfNumberOfInstanceVariables
						put: (deepCopier references
							at: fieldOfSelf
							ifAbsent: [ fieldOfSelf veryDeepCopyWith: deepCopier ]).
					selfNumberOfInstanceVariables := selfNumberOfInstanceVariables - 1 ]].
		currentClass := currentClass superclass ].

	^ copyOfSelf
]

{ #category : '*DeepCopier' }
Object >> veryDeepFixupWith: deepCopier [
	"I have no fields and no superclass.  Catch the super call."

	"avoid to use me we will deprecate it in the future"
]

{ #category : '*DeepCopier' }
Object >> veryDeepInner: deepCopier [
	"No special treatment for inst vars of my superclasses.  Override when some need to be weakly copied.  Object>>veryDeepCopyWith: will veryDeepCopy any inst var whose class does not actually define veryDeepInner:"

	"avoid to use me we will deprecate it in the future"
]
