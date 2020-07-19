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
JollyEForthAssembler >> allocateDataStack [
	"Return stack grows upward, so increment stack pointer to allocate it."
	self incrementWord: (self addressOfMemoryZone: #SP).
	self incrementWord: (self addressOfMemoryZone: #SP).
	self incrementWord: (self addressOfMemoryZone: #SP).
]

{ #category : #macros }
JollyEForthAssembler >> allocateReturnStack [
	"Return stack grows downward, so decrement stack pointer to allocate it."
	self decrementWord: (self addressOfMemoryZone: #RP).
	self decrementWord: (self addressOfMemoryZone: #RP).
	self decrementWord: (self addressOfMemoryZone: #RP).
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
		data: string encodeAsASCII;
		label: (assemblyLabel , '-xt') asSymbol.
				
	previousWordAddress := assemblyLabel
]

{ #category : #accessing }
JollyEForthAssembler >> currentGenerationAddress [
	^ currentGenerationAddress ifNil: [ currentGenerationAddress := (self memoryLayout reservedMemoryZoneNamed: #DICTIONARY) startAddress ]
]

{ #category : #macros }
JollyEForthAssembler >> deallocateDataStack [
	"Return stack grows upward, so decrement stack pointer to allocate it."
	self decrementWord: (self addressOfMemoryZone: #SP).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self decrementWord: (self addressOfMemoryZone: #SP).
]

{ #category : #macros }
JollyEForthAssembler >> deallocateReturnStack [
	"Return stack grows downward, so increment stack pointer to deallocate it."
	self incrementWord: (self addressOfMemoryZone: #RP).
	self incrementWord: (self addressOfMemoryZone: #RP).
	self incrementWord: (self addressOfMemoryZone: #RP).
]

{ #category : #'loop-and-branches' }
JollyEForthAssembler >> defineBranch [
	self codeDefinitionHeaderWithLexicon: 0 name: 'BRANCH' label: #branchWord.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #IP).
	self next.
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineCFetch [
	"( a -- b )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'C@' label: #fetchWord.
	
	self moveCharFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #SP) + 2.
	self moveCharFrom: 0 to: (self addressOfMemoryZone: #SP). "Erase high-weight byte of the cell."
	self moveCharFrom: 0 to: (self addressOfMemoryZone: #SP) + 1. "Erase middle-weight byte of the cell."
	self next
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineCStore [
	"( b a -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'C!' label: #cStoreWord.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X). "Address to store cell at."
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y). "Cell containing byte to store."
	self deallocateDataStack.
	self moveCharFrom: (self addressOfMemoryZone: #Y) + 2 toIndirect: (self addressOfMemoryZone: #X). "Move only the byte that is stored in low-weight byte of the cell."
	self next
]

{ #category : #'loop-and-branches' }
JollyEForthAssembler >> defineConditionalBranch [
	self codeDefinitionHeaderWithLexicon: 0 name: '?BRANCH' label: #conditionalBranchWord.
	
	self moveCharFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self deallocateDataStack.
	
	self cmpWord: (self addressOfMemoryZone: #X) withWord: (self addressOfMemoryZone: #ZERO_WORD).
	self jumpIfEqual: #conditionalBranchWord1.
	
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self next.
	
	self label: #conditionalBranchWord1;
		moveWordFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #IP);
		next.
	
	
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
	"Push IP on return stack."
	self allocateReturnStack.
	self
		moveWordFrom: (self addressOfMemoryZone: #IP)
		toIndirect: (self addressOfMemoryZone: #RP).
	
	self incrementWord: (self addressOfMemoryZone: #WP).
	self incrementWord: (self addressOfMemoryZone: #WP).
	self incrementWord: (self addressOfMemoryZone: #WP).
	
	self moveWordFrom: (self addressOfMemoryZone: #WP) to: (self addressOfMemoryZone: #IP).
	
	self next.
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineDoLit [
	"( -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'DOLIT' label: #doLitWord.
	self moveWordFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #X).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	self incrementWord: (self addressOfMemoryZone: #IP).
	
	"Pushes value in #X on the data stack."
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self next
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineExecute [
	"( ca -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'EXECUTE' label: #executeWord.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self decrementWord: (self addressOfMemoryZone: #SP).
	self jumpIndirect: (self addressOfMemoryZone: #X)
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
	self deallocateReturnStack.
	self next
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineFetch [
	"( a -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: '@' label: #fetchWord.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #SP).
	self next
]

{ #category : #'loop-and-branches' }
JollyEForthAssembler >> defineNext [

	self codeDefinitionHeaderWithLexicon: 0 name: 'NEXT' label: #nextWord.
	"Fetch the word at the top of return stack into #X register."
	self moveWordFromIndirect: (self addressOfMemoryZone: #RP) to: (self addressOfMemoryZone: #X).
	"Check if X = 0."
	self cmp: (self addressOfMemoryZone: #X) with: (self addressOfMemoryZone: #ZERO_WORD).
	self jumpIfEqual: #nextWord1.
	
	"If X ~= 0, decrement it and update top of the stack."
	self decrementWord: (self addressOfMemoryZone: #X).
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #RP).
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #IP).
	self next.
	
	"If x = 0,"
	self label: #nextWord1;
		deallocateReturnStack; "Pop the index"
		"Exit loop."
		incrementWord: (self addressOfMemoryZone: #IP);
		incrementWord: (self addressOfMemoryZone: #IP);
		incrementWord: (self addressOfMemoryZone: #IP);
		next.
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineStore [
	"( w a -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: '!' label: #storeWord.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X). "Address to store cell at."
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y). "Cell to store."
	self deallocateDataStack.
	self moveWordFrom: (self addressOfMemoryZone: #Y) toIndirect: (self addressOfMemoryZone: #X).
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
		JUMP W;
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
