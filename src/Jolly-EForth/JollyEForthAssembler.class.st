Class {
	#name : #JollyEForthAssembler,
	#superclass : #JollyAssembler,
	#instVars : [
		'previousWordAddress',
		'currentGenerationAddress'
	],
	#category : #'Jolly-EForth'
}

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
	
	self label: #exit.
	self moveWordFromIndirect: #RP to: #IP.
	self incrementWord: #RP.
	self incrementWord: #RP.
	self incrementWord: #RP.
	self next
]

{ #category : #initialization }
JollyEForthAssembler >> initialize [
	super initialize.
	self memoryLayout: JollyEForthLayout new.
	previousWordAddress := 0 asBPAddress.
]

{ #category : #'inner interpreter' }
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
	
	self moveWordFromIndirect: #IP to: #WP.
	"Cells are 24bits, 3 bytes so need to increment #IP 3 times."
	self incrementWord: #IP.
	self incrementWord: #IP.
	self incrementWord: #IP.
	"We need to jump to the address stored in memory at address pointed by #WP.
	 So we fetch this word and store it in #WP (thus erasing the pointer to this address).
	"
	self moveWordFromIndirect: #WP to: #WP.
	self jump: #WP
]

{ #category : #accessing }
JollyEForthAssembler >> previousWordAddress [
	^ previousWordAddress
]
