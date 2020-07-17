Class {
	#name : #JollyEForthAssembler,
	#superclass : #JollyAssembler,
	#instVars : [
		'previousWordAddress',
		'currentGenerationAddress'
	],
	#category : #'Jolly-EForth'
}

{ #category : #accessing }
JollyEForthAssembler >> addressOfMemoryZone: aSymbol [
	^ (self memoryLayout reservedMemoryZoneNamed: aSymbol) address
]

{ #category : #macros }
JollyEForthAssembler >> codeDefinitionHeaderWithLexicon: lexiconInteger name: string label: assemblyLabel [
	" Compiles a code definition header.
	"
	self
		label: assemblyLabel;
		data: previousWordAddress;
		data: {lexiconInteger} asByteArray;
		data: {string size} asByteArray;
		data: string encodeAsASCII.
				
	previousWordAddress := assemblyLabel
]

{ #category : #accessing }
JollyEForthAssembler >> currentGenerationAddress [
	^ currentGenerationAddress ifNil: [ currentGenerationAddress := (self memoryLayout reservedMemoryZoneNamed: #DICTIONARY) startAddress ]
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineDoList [
	"In a colon word, the first four byte in the code field must be a subroutine call
	 instruction to process the address list following this call instruction.
	 This address list processing subroutine is named doLIST.
	
	 doLIST
		- pushes the contents in IP onto the return stack,
		- copies the address of the first entry in its address list into IP and then
		- calls $NEXT.
	 
	 $NEXT will then start executing this list of addresses in sequence.
	"
	"
	PUSH IP
	IP = W + CELL_SIZE;
	$NEXT
	"
	
	self label: #doLIST.
	"Push IP on return stack (that grows downward)."
	self moveWordFrom: #IP toIndirect: #RP.
	self decrementWord: #RP.
	self decrementWord: #RP.
	self decrementWord: #RP.
	"Pop address from data stack and store it in #IP register (datastack grows upward)."
	self moveWordFromIndirect: #SP to: #IP.
	self decrementWord: #SP.
	self decrementWord: #SP.
	self decrementWord: #SP.
	self next.
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineDoLit [
	self codeDefinitionHeaderWithLexicon: 0 name: 'DOLIT' label: #doLitWord.
	self moveCharFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #X).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	
	"Pushes value in #X on the data stack."
	self incrementWord: (self addressOfMemoryZone: #SP).
	self incrementWord: (self addressOfMemoryZone: #SP).
	self incrementWord: (self addressOfMemoryZone: #SP).
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self next
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineExecute [
	self codeDefinitionHeaderWithLexicon: 0 name: 'EXECUTE' label: #executeWord.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self jump: (self addressOfMemoryZone: #X)
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineExit [
	"EXIT is a code word which undoes what doLIST accomplished.
	 EXIT pops the top item on the return stack into the IP register.
	 Consequently, IP points to the address following the colon word just executed.
	 EXIT then invokes $NEXT which continues the processing of the word list, briefly
	 interrupted by the last colon word in this word list.
	"
	"
	POP IP
	$NEXT
	"
	
	self codeDefinitionHeaderWithLexicon: 0 name: 'EXIT' label: #exitWord.
	
	"Pop address from return stack."
	self moveWordFromIndirect: (self addressOfMemoryZone: #RP) to: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #RP).
	self incrementWord: (self addressOfMemoryZone: #RP).
	self incrementWord: (self addressOfMemoryZone: #RP).
	self next
]

{ #category : #initialization }
JollyEForthAssembler >> initialize [
	super initialize.
	self memoryLayout: JollyEForthLayout new.
	previousWordAddress := 0 asBPAddress.
]

{ #category : #macros }
JollyEForthAssembler >> next [
	"The function of $NEXT is to
		- fetch the next word pointed to by the Interpreter Pointer IP,
		- increment IP to point to the next word in the word list, and
		- jump to the address just fetched.
	 Since a word address points to a code field containing executable machine instructions,
	 executing a word means jumping directly to the code field pointed to by the word address.
	
	 The pseudo-code for $NEXT is:
	
		W = *IP;
		IP = IP + CELL_SIZE;
		JUMP *W;
	"
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #WP).
	"Cells are 24bits, 3 bytes so need to increment #IP 3 times."
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).

	self jumpIndirect: (self addressOfMemoryZone: #WP)
]

{ #category : #accessing }
JollyEForthAssembler >> previousWordAddress [
	^ previousWordAddress
]
