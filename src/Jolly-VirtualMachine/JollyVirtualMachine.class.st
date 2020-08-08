Class {
	#name : #JollyVirtualMachine,
	#superclass : #Object,
	#instVars : [
		'memory',
		'programCounter',
		'announcer'
	],
	#pools : [
		'JollyConstants'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #announcements }
JollyVirtualMachine >> announce: anAnnouncement [
	announcer
		ifNil: [ ^ self ].
	
	self announcer announce: anAnnouncement
]

{ #category : #announcements }
JollyVirtualMachine >> announceAboutMoveByteFrom: fromAddress to: toAddress becauseOfInstructionAtAddress: instructionAddress [
	self announce: (JollyAboutToMoveByte vm: self address: instructionAddress from: fromAddress to: toAddress)
]

{ #category : #announcements }
JollyVirtualMachine >> announceAboutToExecutePrimitiveWithId: primitiveId resultsAddress: resultsAddress becauseOfInstructionAtAddress: instructionAddress [
	self announce: (JollyAboutToExecutePrimitive vm: self address: instructionAddress primitiveId: primitiveId resultsAddress: resultsAddress)
]

{ #category : #announcements }
JollyVirtualMachine >> announceAboutToJumpTo: jumpAddress becauseOfInstructionAtAddress: instructionAddress [
	self announce: (JollyAboutToJump vm: self address: instructionAddress jump: jumpAddress)
]

{ #category : #announcements }
JollyVirtualMachine >> announceAboutToLoadPCBecauseOfInstructionAtAddress: instructionAddress [
	self announce: (JollyAboutToLoadProgramCounter vm: self address: instructionAddress)
]

{ #category : #accessing }
JollyVirtualMachine >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #running }
JollyVirtualMachine >> executeInnerLoop [
	| fromAddress toAddress newProgramCounter |
	self isPrimitiveReady
		ifTrue: [ self executePrimitive ].
	
	fromAddress := self extract: ADDRESS_SIZE bytesStartingAt: programCounter.
	toAddress := self extract: ADDRESS_SIZE bytesStartingAt: programCounter + ADDRESS_SIZE.
	self announceAboutMoveByteFrom: fromAddress to: toAddress becauseOfInstructionAtAddress: programCounter.
	self
		memoryAt: toAddress
		put: (self memoryAt: fromAddress).
		
	newProgramCounter := self extract: ADDRESS_SIZE bytesStartingAt: programCounter + (2*ADDRESS_SIZE).
	self announceAboutToJumpTo: newProgramCounter becauseOfInstructionAtAddress: programCounter.
	
	programCounter := newProgramCounter
]

{ #category : #running }
JollyVirtualMachine >> executeInnerLoopUntilReachAddress: address [
	^ self executeInnerLoopUntilReachAddress: address orExecutedInstructionsCountReach: Float infinity
]

{ #category : #running }
JollyVirtualMachine >> executeInnerLoopUntilReachAddress: address orExecutedInstructionsCountReach: instructionCount [
	| count |
	count := 0.
	[ programCounter ~= address and: [ count < instructionCount ] ]
		whileTrue: [ 
			self executeInnerLoop.
			count := count + 1 ].
	^ count
]

{ #category : #primitives }
JollyVirtualMachine >> executePrimitive [
	| primitiveId |
	primitiveId := self memoryAt: PRIMITIVE_CALL_ID_ADDRESS
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

{ #category : #testing }
JollyVirtualMachine >> isPrimitiveReady [
	^ (self memoryAt: PRIMITIVE_IS_READY_ADDRESS) = PRIMITIVE_READY
]

{ #category : #running }
JollyVirtualMachine >> loadProgramCounter [
	self announceAboutToLoadPCBecauseOfInstructionAtAddress: 0.
	programCounter := self extract: ADDRESS_SIZE bytesStartingAt: PROGRAM_COUNTER_ADDRESS.
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

{ #category : #primitives }
JollyVirtualMachine >> primitiveCloseFile [
	"A primitive that close the filestream for id provided as argument.
	 
	 Reads the byte pointed by the result pointer, the value stored there is
	 the id of the filestream.
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveFail [
	<jollyPrimitive: #PRIMITIVE_ID_FAIL>
	"A primitive that always fails.
	 Writes the PRIMITIVE_FAILED_RESULT_CODE at PRIMITIVE_RESULT_CODE_ADDRESS.
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveGetChar [
	<jollyPrimitive: #PRIMITIVE_ID_GET_CHAR>
	"A primitive that get a character from the stream with id provided as
	 argument.
	
	 Reads the byte pointed by the result pointer, the char stored there
	 is the id of the stream to read from.
	 Reads the next byte from this stream and stores it in the byte pointed
	 by the result pointer (thus, the id of the input stream is erased!).
 
	 The special stream with id PRIMITIVE_FILE_INPUT_STREAM_STDIN is stdin
	 stream.
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveIsFileOpen [
	"A primitive that determinate if the file stream with id provided as argument
	 is open or not.
	 
	 Reads the byte pointed by the result pointer, the char stored there
	 is id of the stream to determinate if open or not.
	 
	 Stores PRIMITIVE_FILE_IS_CLOSED or PRIMITIVE_FILE_IS_OPEN in the byte pointed
	 by the result pointer (thus, the id of the stream is erased!).
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveNop [
	<jollyPrimitive: #PRIMITIVE_ID_NOPE>
	" A primitive that does nothing.
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveOpenFile [
	"A primitive that open a new filestream for the file path provided as argument
	 and with the open mode provided as argument.
	 
	 Reads the byte pointed by the result pointer, the value stored there is
	 the open mode of the file.
	 Currently, this value can be one of the following:
	 - PRIMITIVE_FILE_MODE_READ
	 - PRIMITIVE_FILE_MODE_WRITE
	 - PRIMITIVE_FILE_MODE_APPEND
	 
	 Then, reads the null-terminated ASCII string directly consecutive to the open
	 mode byte in memory.
	 This string encodes the path of the file to open.
	 
	 If the primitive succeed, the id of the stream open is written in the byte
	 pointed by the result pointer.
	 This stream id will be needed by primitives that read from or write bytes to
	 file streams.
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitivePutChar [
	<jollyPrimitive: #PRIMITIVE_ID_PUT_CHAR>
	" A primitive that put the character provided as argument on the stream
	 which id is provided as argument.

	 Reads the byte pointed by the result pointer, the char stored there
	 is the value of the character to put on the stream.
	 Reads the byte pointed by the result pointer incremented of 1, the 
	 char stored there is the id of the stream to write to.

	 The special stream with id PRIMITIVE_FILE_OUTPUT_STREAM_STDOUT is sdout
	 stream.
	 The special stream with id PRIMITIVE_FILE_OUTPUT_STREAM_STDERR is sderr
	 stream.
	"
	self flag: #TODO; halt
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveSelectorForId: anInteger [
	^ (Pragma allNamed: #jollyPrimitive: in: self class)
		detect: [ :pragma |
			(self class sharedPools anySatisfy: [ :pool |
				(pool hasClassVarNamed: pragma arguments first) and: [ (pool readClassVariableNamed: pragma arguments first) = anInteger ] ]) ]
]

{ #category : #primitives }
JollyVirtualMachine >> primitiveStop [
	<jollyPrimitive: #PRIMITIVE_ID_STOP_VM>
	"Stops virtual machine execution.
	"
	self flag: #TODO; halt
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

{ #category : #announcements }
JollyVirtualMachine >> when: anAnnouncementClass send: aSelector to: anObject [
	^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]
