Class {
	#name : #JollyEForthAssembler,
	#superclass : #JollyAssembler,
	#instVars : [
		'previousWordAddress',
		'currentGenerationAddress',
		'assemblerWordsDictionary'
	],
	#classVars : [
		'PRIMITIVE_FILE_STREAM_STDERR',
		'PRIMITIVE_FILE_STREAM_STDIN',
		'PRIMITIVE_FILE_STREAM_STDOUT',
		'PRIMITIVE_ID_CLOSE_FILE',
		'PRIMITIVE_ID_FAIL',
		'PRIMITIVE_ID_GET_CHAR',
		'PRIMITIVE_ID_NOPE',
		'PRIMITIVE_ID_OPEN_FILE',
		'PRIMITIVE_ID_PUT_CHAR',
		'PRIMITIVE_ID_STOP_VM',
		'PRIMITIVE_NOT_READY',
		'PRIMITIVE_READY'
	],
	#category : #'Jolly-EForth'
}

{ #category : #'class initialization' }
JollyEForthAssembler class >> initialize [
	PRIMITIVE_ID_NOPE := 0.
	PRIMITIVE_ID_FAIL := 1.
	PRIMITIVE_ID_PUT_CHAR := 2.
	PRIMITIVE_ID_GET_CHAR := 3.
	PRIMITIVE_ID_STOP_VM := 4.
	PRIMITIVE_ID_OPEN_FILE := 5.
	PRIMITIVE_ID_CLOSE_FILE := 6.
	
	PRIMITIVE_NOT_READY := 0.
	PRIMITIVE_READY := 1.

	PRIMITIVE_FILE_STREAM_STDIN := 0.
	PRIMITIVE_FILE_STREAM_STDOUT := 1.
	PRIMITIVE_FILE_STREAM_STDERR := 2
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
				
	previousWordAddress := assemblyLabel.
	assemblerWordsDictionary at: string put: (assemblyLabel , '-xt') asSymbol
]

{ #category : #macros }
JollyEForthAssembler >> colonDefinitionHeaderWithLexicon: lexiconInteger name: string label: assemblyLabel [
	" Compiles a colon definition header.
	"
	| callLabel |
	callLabel := ('callLabel' , UUIDGenerator next asString) asSymbol.
	self codeDefinitionHeaderWithLexicon: lexiconInteger name: string label: assemblyLabel.
	
	self allocateReturnStack.
	self moveWordFrom: callLabel toIndirect: (self addressOfMemoryZone: #RP).
	self jump: #doLIST.
	
	self label: callLabel.
]

{ #category : #helpers }
JollyEForthAssembler >> compile: forthCodeAsArray [
	forthCodeAsArray do: [ :token |
		self compileToken: token ]
]

{ #category : #helpers }
JollyEForthAssembler >> compileToken: token [
	token isString
		ifTrue: [ 
			self data: (assemblerWordsDictionary at: token).
			^ self ].
	
	token isInteger
		ifTrue: [ 
			self data: (assemblerWordsDictionary at: 'DOLIT').
			self halt: #TODO. "See how to manage compiling the literal here."
			^ self ].
	
	self error
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

{ #category : #'common functions' }
JollyEForthAssembler >> define2Drop [
	<eforthWord: 3>
	"( w w -- )"
	self colonDefinitionHeaderWithLexicon: 0 name: '2DROP' label: #'2DropWord'.
	
	self label: #'2DropWord-compiled'.
	self compile: #('DROP' 'DROP').
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> define2Dup [
	<eforthWord: 4>
	"( w1 w2 -- w1 w2 w1 w2 )"
	self colonDefinitionHeaderWithLexicon: 0 name: '2DUP' label: #'2DupWord'.
	
	self label: #'2DupWord-compiled'.
	self compile: #('OVER' 'OVER').
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> defineAbs [
	<eforthWord: 11>
	"( n -- +n )"
	self colonDefinitionHeaderWithLexicon: 0 name: 'ABS' label: #'absWord'.
	
	self label: #'absWord-compiled'.
	self compile: #('DUP' '0<' 'IF' 'NEGATE' 'THEN').
	self next
]

{ #category : #'logical words' }
JollyEForthAssembler >> defineBitwiseAnd [
	<eforthPrimitiveDefinition>
	"( w w -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'AND' label: #andWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y).
	
	self bitAnd: (self addressOfMemoryZone: #X) with: (self addressOfMemoryZone: #Y) into: (self addressOfMemoryZone: #Z).
	self bitAnd: (self addressOfMemoryZone: #X) + 1 with: (self addressOfMemoryZone: #Y) + 1 into: (self addressOfMemoryZone: #Z) + 1.
	self bitAnd: (self addressOfMemoryZone: #X) + 2 with: (self addressOfMemoryZone: #Y) + 2 into: (self addressOfMemoryZone: #Z) + 2.
	
	self moveWordFrom: (self addressOfMemoryZone: #Z) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#andWord , '-next') asSymbol.
	self next.
]

{ #category : #'logical words' }
JollyEForthAssembler >> defineBitwiseOr [
	<eforthPrimitiveDefinition>
	"( w w -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'OR' label: #orWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y).
	
	self bitOr: (self addressOfMemoryZone: #X) with: (self addressOfMemoryZone: #Y) into: (self addressOfMemoryZone: #Z).
	self bitOr: (self addressOfMemoryZone: #X) + 1 with: (self addressOfMemoryZone: #Y) + 1 into: (self addressOfMemoryZone: #Z) + 1.
	self bitOr: (self addressOfMemoryZone: #X) + 2 with: (self addressOfMemoryZone: #Y) + 2 into: (self addressOfMemoryZone: #Z) + 2.
	
	self moveWordFrom: (self addressOfMemoryZone: #Z) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#orWord , '-next') asSymbol.
	self next.
]

{ #category : #'logical words' }
JollyEForthAssembler >> defineBitwiseXor [
	<eforthPrimitiveDefinition>
	"( w w -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'XOR' label: #xorWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y).
	
	self bitXor: (self addressOfMemoryZone: #X) with: (self addressOfMemoryZone: #Y) into: (self addressOfMemoryZone: #Z).
	self bitXor: (self addressOfMemoryZone: #X) + 1 with: (self addressOfMemoryZone: #Y) + 1 into: (self addressOfMemoryZone: #Z) + 1.
	self bitXor: (self addressOfMemoryZone: #X) + 2 with: (self addressOfMemoryZone: #Y) + 2 into: (self addressOfMemoryZone: #Z) + 2.
	
	self moveWordFrom: (self addressOfMemoryZone: #Z) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#xorWord , '-next') asSymbol.
	self next.
]

{ #category : #'loop-and-branches' }
JollyEForthAssembler >> defineBranch [
	<eforthPrimitiveDefinition>
	self codeDefinitionHeaderWithLexicon: 0 name: 'BRANCH' label: #branchWord.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #IP) to: (self addressOfMemoryZone: #IP).
	self next.
]

{ #category : #io }
JollyEForthAssembler >> defineBye [
	<eforthPrimitiveDefinition>
	"( -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'BYE' label: #byeWord.
	
	"4 = stop_vm"
	self moveCharFrom: PRIMITIVE_ID_STOP_VM to: #PRIMITIVE_CALL_ID.
	"Trigger primitive."
	self moveCharFrom: PRIMITIVE_READY to: #PRIMITIVE_IS_READY.
	
	self label: #'byeWord-next'.
	self next.
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineCFetch [
	<eforthPrimitiveDefinition>
	"( a -- b )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'C@' label: #cFetchWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self moveCharFromIndirect: (self addressOfMemoryZone: #X) to: (self addressOfMemoryZone: #X) + 2.
	self moveCharFrom: 0 to: (self addressOfMemoryZone: #X). "Erase high-weight byte of the cell."
	self moveCharFrom: 0 to: (self addressOfMemoryZone: #X) + 1. "Erase middle-weight byte of the cell."
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self next
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineCStore [
	<eforthPrimitiveDefinition>
	"( b a -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'C!' label: #cStoreWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X). "Address to store cell at."
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y). "Cell containing byte to store."
	self moveCharFrom: (self addressOfMemoryZone: #Y) + 2 toIndirect: (self addressOfMemoryZone: #X). "Move only the byte that is stored in low-weight byte of the cell."
	self next
]

{ #category : #'loop-and-branches' }
JollyEForthAssembler >> defineConditionalBranch [
	<eforthPrimitiveDefinition>
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

{ #category : #'common functions' }
JollyEForthAssembler >> defineConditionalDup [
	"<eforthWord: 1>"self flag: #TODO.
	"( w -- w w | 0 )"
	self colonDefinitionHeaderWithLexicon: 0 name: '?DUP' label: #'conditionalDupWord'.
	
	self label: #'conditionalDupWord-compiled'.
	self compile: #('DUP' 'IF' 'DUP' 'THEN').
	self next
]

{ #category : #'return stack' }
JollyEForthAssembler >> defineCopyTopOfReturnStackToDataStack [
	<eforthPrimitiveDefinition>
	"( w -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'R@' label: #copyTopOfReturnStackToDataStack.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #RP) to: (self addressOfMemoryZone: #X).
	self deallocateReturnStack.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self allocateReturnStack.
	self next.
]

{ #category : #'common functions' }
JollyEForthAssembler >> defineDNegate [
	"<eforthWord: 8>"self flag: #TODO.
	"( d -- -d )"
	self colonDefinitionHeaderWithLexicon: 0 name: 'DNEGATE' label: #'dnegateWord'.
	
	self label: #'dnegateWord-compiled'.
	self compile: #('NOT' '>R' 'NOT' 1 'UM+' 'R>' '+').
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> defineDPlus [
	<eforthWord: 9>
	"( d d -- -d )"
	self colonDefinitionHeaderWithLexicon: 0 name: 'DPLUS' label: #'dplusWord'.
	
	self label: #'dplusWord-compiled'.
	self compile: #('>R' 'SWAP' '>R' 'UM+' 'R>' 'R>' '+' '+').
	self next
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineDoList [
	<eforthPrimitiveDefinition>
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
	<eforthPrimitiveDefinition>
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

{ #category : #'data stack' }
JollyEForthAssembler >> defineDrop [
	<eforthPrimitiveDefinition>
	"( w -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'DROP' label: #dropWord.
	
	self deallocateDataStack.
	
	self label: (#dropWord , '-next') asSymbol.
	self next
]

{ #category : #'data stack' }
JollyEForthAssembler >> defineDup [
	<eforthPrimitiveDefinition>
	"( w -- w w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'DUP' label: #dupWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self allocateDataStack.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self next
]

{ #category : #'inner interpreter' }
JollyEForthAssembler >> defineExecute [
	<eforthPrimitiveDefinition>
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
	<eforthPrimitiveDefinition>
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
	<eforthPrimitiveDefinition>
	"( a -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: '@' label: #fetchWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self moveWordFromIndirect: (self addressOfMemoryZone: #X) to: (self addressOfMemoryZone: #Y).
	self moveWordFrom: (self addressOfMemoryZone: #Y) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self next
]

{ #category : #'logical words' }
JollyEForthAssembler >> defineIsNegative [
	<eforthPrimitiveDefinition>
	"( n -- f )"
	self codeDefinitionHeaderWithLexicon: 0 name: '0<' label: #isNegativeWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self bitAnd: (self addressOfMemoryZone: #X) with: 2r10000000 into: (self addressOfMemoryZone: #Y).
	
	self cmp: (self addressOfMemoryZone: #Y) with: 2r10000000.
	self jumpIfEqual: #isNegative.
	
	"If sign bit is equal to 0, push 0 on the data stack."
	self moveCharFrom: 16r00 to: (self addressOfMemoryZone: #X).
	self moveCharFrom: 16r00 to: (self addressOfMemoryZone: #X) + 1.
	self moveCharFrom: 16r00 to: (self addressOfMemoryZone: #X) + 2.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self jump: (#isNegativeWord , '-next') asSymbol.
	
	
	"If sign bit is equal to 1, push -1 (2r100000000000000000000000) on the data stack."
	self label: #isNegative.
	self moveCharFrom: 16rFF to: (self addressOfMemoryZone: #X).
	self moveCharFrom: 16rFF to: (self addressOfMemoryZone: #X) + 1.
	self moveCharFrom: 16rFF to: (self addressOfMemoryZone: #X) + 2.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#isNegativeWord , '-next') asSymbol.
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> defineMinus [
	<eforthWord: 10>
	"( w w -- w )"
	self colonDefinitionHeaderWithLexicon: 0 name: '-' label: #'minusWord'.
	
	self label: #'minusWord-compiled'.
	self compile: #('NEGATE' '+').
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> defineNegate [
	<eforthWord: 7>
	"( n -- -n )"
	self colonDefinitionHeaderWithLexicon: 0 name: 'NEGATE' label: #'negateWord'.
	
	self label: #'negateWord-compiled'.
	self compile: #('NOT' 1 '+').
	self next
]

{ #category : #'loop-and-branches' }
JollyEForthAssembler >> defineNext [
	<eforthPrimitiveDefinition>
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

{ #category : #'common functions' }
JollyEForthAssembler >> defineNot [
	<eforthWord: 6>
	"( w -- w )"
	self colonDefinitionHeaderWithLexicon: 0 name: 'NOT' label: #'notWord'.
	
	self label: #'notWord-compiled'.
	self compile: #(-1 'XOR').
	self next
]

{ #category : #'data stack' }
JollyEForthAssembler >> defineOver [
	<eforthPrimitiveDefinition>
	"( w1 w2 -- w1 w2 w1 )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'OVER' label: #overWord.
	
	self deallocateDataStack.
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X). "w1"
	self allocateDataStack.
	self allocateDataStack.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#overWord , '-next') asSymbol.
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> definePlus [
	<eforthWord: 5>
	"( w w -- w )"
	self colonDefinitionHeaderWithLexicon: 0 name: '+' label: #'plusWord'.
	
	self label: #'plusWord-compiled'.
	self compile: #('UM+' 'DROP').
	self next
]

{ #category : #'return stack' }
JollyEForthAssembler >> definePopDataStackToReturnStack [
	<eforthPrimitiveDefinition>
	"( w -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: '>R' label: #popDataStackToReturnStack.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self allocateReturnStack.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #RP).
	self next.
]

{ #category : #'return stack' }
JollyEForthAssembler >> definePopReturnStackToDataStack [
	<eforthPrimitiveDefinition>
	"( -- w )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'R>' label: #popReturnStackToDataStack.
	
	self moveWordFromIndirect: (self addressOfMemoryZone: #RP) to: (self addressOfMemoryZone: #X).
	self deallocateReturnStack.
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self next.
]

{ #category : #helpers }
JollyEForthAssembler >> definePrimitives [
	self primitiveDefinitionPragmas do: [ :pragma |
		pragma methodSelector value: self ]
]

{ #category : #'return stack' }
JollyEForthAssembler >> defineRPFetch [
	<eforthPrimitiveDefinition>
	"( -- a )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'RP@' label: #rpFetchWord.
	
	self moveWordFrom: (self addressOfMemoryZone: #RP) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#rpFetchWord , '-next') asSymbol.
	self next
]

{ #category : #'return stack' }
JollyEForthAssembler >> defineRPStore [
	<eforthPrimitiveDefinition>
	"( a -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'RP!' label: #rpStoreWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #RP).
	
	self label: (#rpStoreWord, '-next') asSymbol.
	self next
]

{ #category : #'common functions' }
JollyEForthAssembler >> defineRot [
	<eforthWord: 2>
	"( w1 w2 w3 -- w2 w3 w1 )"
	self colonDefinitionHeaderWithLexicon: 0 name: 'ROT' label: #rotWord.
	
	self label: #'rotWord-compiled'.
	self compile: #('>R' 'SWAP' 'R>' 'SWAP').
	self next
]

{ #category : #'data stack' }
JollyEForthAssembler >> defineSPFetch [
	<eforthPrimitiveDefinition>
	self codeDefinitionHeaderWithLexicon: 0 name: 'SP@' label: #spFetchWord.
	
	self moveWordFrom: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#spFetchWord , '-next') asSymbol.
	self next
]

{ #category : #'data stack' }
JollyEForthAssembler >> defineSPStore [
	<eforthPrimitiveDefinition>
	self codeDefinitionHeaderWithLexicon: 0 name: 'SP!' label: #spStoreWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self moveWordFrom: (self addressOfMemoryZone: #X) to: (self addressOfMemoryZone: #SP).
	
	self label: (#spStoreWord, '-next') asSymbol.
	self next
]

{ #category : #'memory-access' }
JollyEForthAssembler >> defineStore [
	<eforthPrimitiveDefinition>
	"( w a -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: '!' label: #storeWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X). "Address to store cell at."
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y). "Cell to store."
	self moveWordFrom: (self addressOfMemoryZone: #Y) toIndirect: (self addressOfMemoryZone: #X).
	self next
]

{ #category : #'data stack' }
JollyEForthAssembler >> defineSwap [
	<eforthPrimitiveDefinition>
	"( w1 w2 -- w2 w1 )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'SWAP' label: #swapWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X). "w2"
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y). "w1"
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self moveWordFrom: (self addressOfMemoryZone: #Y) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#swapWord , '-next') asSymbol.
	self next
]

{ #category : #io }
JollyEForthAssembler >> defineTX [
	<eforthPrimitiveDefinition>
	"( c -- )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'TX!' label: #txWord.
		
	self deallocateDataStack.
	self moveWordFrom: (self addressOfMemoryZone: #SP) to: (#PRIMITIVE_RESULT_HIGH forAssembler: self) address.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self moveCharFrom: (self addressOfMemoryZone: #X) + 2 to: (self addressOfMemoryZone: #X).
	self moveCharFrom: 0 to: (self addressOfMemoryZone: #X) + 1.
	
	self
		"2 = put_char primitive id"
		moveCharFrom: PRIMITIVE_ID_PUT_CHAR to: #PRIMITIVE_CALL_ID;
		"Trigger primitive."
		moveCharFrom: PRIMITIVE_READY to: #PRIMITIVE_IS_READY.
		
	self next
	
]

{ #category : #'primitive arithmetic' }
JollyEForthAssembler >> defineUMPlus [
	<eforthPrimitiveDefinition>
	"( w w -- w cy )"
	self codeDefinitionHeaderWithLexicon: 0 name: 'UM+' label: #umPlusWord.
	
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #X).
	self deallocateDataStack.
	self moveWordFromIndirect: (self addressOfMemoryZone: #SP) to: (self addressOfMemoryZone: #Y).
	
	self label: #umPlusLoop.
	self cmpWord: (self addressOfMemoryZone: #Y) withWord: (self addressOfMemoryZone: #ZERO_WORD).
	self jumpIfEqual: #stopUmPlusLoop.
	
	self incrementWord: (self addressOfMemoryZone: #X).
	self decrementWord:  (self addressOfMemoryZone: #Y).
	
	self bitOr: #CARRY with: #D into: #D.
	
	self jump: #umPlusLoop.
	
	self label: #stopUmPlusLoop.
	self moveCharFrom: #CARRY to: #D. "Backup CARRY flag into #D register"
	self moveWordFrom: (self addressOfMemoryZone: #X) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self moveCharFrom: #D to: #ZERO.
	self jumpIfNotEqual: #no_carry.
	self label: #debug.
	self incrementWord: (self addressOfMemoryZone: #ZERO_WORD) into: (self addressOfMemoryZone: #Y).
	self moveWordFrom: (self addressOfMemoryZone: #Y) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	self jump: (#umPlusWord , '-next') asSymbol.
	
	self label: #no_carry.
	self moveWordFrom: (self addressOfMemoryZone: #ZERO_WORD) toIndirect: (self addressOfMemoryZone: #SP).
	self allocateDataStack.
	
	self label: (#umPlusWord , '-next') asSymbol.
	self next.
]

{ #category : #helpers }
JollyEForthAssembler >> defineWords [
	self wordDefinitionPragmas do: [ :pragma |
		pragma methodSelector value: self ]
]

{ #category : #initialization }
JollyEForthAssembler >> initialize [
	super initialize.
	self memoryLayout: JollyEForthLayout new.
	previousWordAddress := 0 asBPAddress.
	assemblerWordsDictionary := Dictionary new
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

{ #category : #helpers }
JollyEForthAssembler >> primitiveDefinitionPragmas [
	^ Pragma allNamed: #eforthPrimitiveDefinition in: self class
]

{ #category : #helpers }
JollyEForthAssembler >> wordDefinitionPragmas [
	^ (Pragma allNamed: #eforthWord: in: self class)
		sorted: [ :p | p arguments first ] asSortFunction
]
