Class {
	#name : #JollyVirtualMachine,
	#superclass : #Object,
	#instVars : [
		'memory',
		'programCounter'
	],
	#pools : [
		'JollyConstants'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #running }
JollyVirtualMachine >> executeInnerLoop [
	Transcript
		show: programCounter hex;
		show: ' - ';
		show: (self extract: ADDRESS_SIZE bytesStartingAt: programCounter) hex;
		show: ',';
		show: (self extract: ADDRESS_SIZE bytesStartingAt: programCounter + 3) hex;
		show: ',';
		show: (self extract: ADDRESS_SIZE bytesStartingAt: programCounter + 6) hex;
		cr.
	self
		memoryAt: (self extract: ADDRESS_SIZE bytesStartingAt: programCounter + 3)
		put: (self memoryAt: (self extract: ADDRESS_SIZE bytesStartingAt: programCounter)).
	
	programCounter := self
		extract: ADDRESS_SIZE
		bytesStartingAt: programCounter + 6.
		
	
]

{ #category : #running }
JollyVirtualMachine >> executeInnerLoopUntilReachAddress: address orExecutedInstructionsCountReach: instructionCount [
	| count |
	count := 0.
	[ programCounter ~= address and: [ count < instructionCount ] ]
		whileTrue: [ 
			self executeInnerLoop.
			programCounter = 0 ifTrue: [ self halt ].
			count := count + 1 ].
	^ count
]

{ #category : #'memory manipulation' }
JollyVirtualMachine >> extract: n bytesStartingAt: startAddress [
	"Extract #n bytes starting at the #startAddress and returns the integer formed by those #n bytes concatenated.
	 #startAddress should be included between 0 and the memory size's - 1.
	 Example, if the memory is #[16rFF 16r0F 16r42 16r22], self extract: 2 bytesStartingAt: 2 returns 16r4222"
	| extracted |
	extracted := 16r0.
	startAddress to: startAddress + n - 1 do: [ :memoryIndex |
		extracted := (extracted << 8) | (self memoryAt: memoryIndex) ].
	^ extracted
]

{ #category : #initialization }
JollyVirtualMachine >> initialize [
	super initialize.
	self
		resetMemory
]

{ #category : #running }
JollyVirtualMachine >> loadProgramCounter [
	programCounter := self extract: 3 bytesStartingAt: PROGRAM_COUNTER_ADDRESS.
]

{ #category : #accessing }
JollyVirtualMachine >> memory [
	^ memory
]

{ #category : #accessing }
JollyVirtualMachine >> memory: anObject [
	memory := anObject
]

{ #category : #'memory manipulation' }
JollyVirtualMachine >> memoryAt: anInteger [
	"Access the memory with index starting at 0 and finishing at self memory size - 1."
	^ self memory at: anInteger + 1
]

{ #category : #'memory manipulation' }
JollyVirtualMachine >> memoryAt: anInteger put: aByte [
	"Set the memory with index starting at 0 and finishing at self memory size - 1."
	^ self memory at: anInteger + 1 put: aByte
]

{ #category : #'memory manipulation' }
JollyVirtualMachine >> memoryAt: address putInteger: anInteger [
	"Write anInteger on the 3 consecutive bytes at address, address+1 and address+2.
	 Big endian encoding is used.
	"
	self
		memoryAt: address put: (anInteger & 16rFF0000) >> 16;
		memoryAt: address + 1 put: (anInteger & 16rFF00) >> 8;
		memoryAt: address + 2 put: (anInteger & 16rFF).
]

{ #category : #'memory manipulation' }
JollyVirtualMachine >> memoryCopy: n bytesFrom: startAddress [
	"Returns a copy of a sub-range of the memory starting at #startAddress and of size #n."
	^ self memory copyFrom: startAddress + 1 to: startAddress + n
]

{ #category : #accessing }
JollyVirtualMachine >> programCounter [
	^ programCounter
]

{ #category : #accessing }
JollyVirtualMachine >> programCounter: anObject [
	programCounter := anObject
]

{ #category : #'memory manipulation' }
JollyVirtualMachine >> resetMemory [
	self memory: (ByteArray new: MEMORY_SIZE)
]
