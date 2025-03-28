Class {
	#name : 'MemoryLoggerTest',
	#superclass : 'TestCase',
	#category : 'Beacon-Core-Tests-Tests',
	#package : 'Beacon-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'testing' }
MemoryLoggerTest >> testEmittingOutsideRunDuringWhenStoppedDoesNotLog [

	| logger |
	logger := MemoryLogger new.
	logger stop.
	logger runDuring: [ 'should be in the log' emit ].
	'Should not be in the log' emit.
	self assert: logger recordingCount equals: 1
]

{ #category : 'testing' }
MemoryLoggerTest >> testRecordOneSignal [
	| logger |
	logger := MemoryLogger new runDuring: [ StringSignal emit: 'test' ].
	self assert: logger recordings size equals: 1.
	self assert: logger recordings first message equals: 'test'
]

{ #category : 'testing' }
MemoryLoggerTest >> testRecordTwoSignalsInTheRightOrder [
	| logger |
	logger := MemoryLogger new
					runDuring: [
						StringSignal emit: 'test1'.
						StringSignal emit: 'test2' ].
	self assert: logger recordings size equals: 2.
	self assert: logger recordings first message equals: 'test1'.
	self assert: logger recordings last message equals: 'test2'
]

{ #category : 'testing' }
MemoryLoggerTest >> testRunDuringStopsAtTheEnd [
	| logger |
	logger := MemoryLogger new.
	logger runDuring: [
		self assert: logger isRunning ].
	self assert: logger isRunning not
]

{ #category : 'testing' }
MemoryLoggerTest >> testWhenStoppedALoggerDoesNotLog [
	| logger |
	logger := MemoryLogger new.
	self deny: logger hasRecordings.
	logger stop. 
	'Should not be in the log' emit.
	self deny: logger hasRecordings
]
