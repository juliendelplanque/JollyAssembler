Class {
	#name : #JollyAssembler,
	#superclass : #BPAbstractAssembler,
	#pools : [
		'BPConstants'
	],
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyAssembler class >> defaultMemoryLayout [
	^ JollyMemoryLayoutV1 new
]

{ #category : #instructions }
JollyAssembler >> add: address1 to: address2 into: resultAddress [
	self lookupBank: (self reservedMemoryZoneNamed: #ADD_PAGE) address from: address1 from: address2 to: resultAddress
]

{ #category : #assembling }
JollyAssembler >> assemble [
	| lastInstruction |
	self flag: #TODO. "Manage this more cleanly."
	lastInstruction := (self instructions reject: #isData) last.
	lastInstruction jump class = BPNextInstructionReference
		ifTrue: [ lastInstruction jump: 0 asBPAddress ].
	^ super assemble
]

{ #category : #instructions }
JollyAssembler >> carryFlag: address1 with: address2 into: resultAddress [
	self lookupBank: (self reservedMemoryZoneNamed: #ADD_CARRY_FLAG_PAGE) address from: address1 from: address2 to: resultAddress
]

{ #category : #instructions }
JollyAssembler >> cmp: address1 with: address2 [
	self cmp: address1 with: address2 into: #ZERO
]

{ #category : #instructions }
JollyAssembler >> cmp: address1 with: address2 into: resultAddress [
	self lookupBank: (self reservedMemoryZoneNamed: #CMP_PAGE) address from: address1 from: address2 to: resultAddress
]

{ #category : #instructions }
JollyAssembler >> cmpWord: address1 withWord: address2 into: resultAddress [
	self cmp: (address1 forAssembler: self) with: (address2 forAssembler: self) into: #A.
	self cmp: (address1 forAssembler: self) + 1 with: (address2 forAssembler: self) + 1 into: #B.
	self add: #A to: #B into: #A.
	self cmp: (address1 forAssembler: self) + 2 with: (address2 forAssembler: self) + 2 into: #B.
	self add: #A to: #B into: #A.
	self cmp: #A with: (TRUE_VALUE * 3).
]

{ #category : #accessing }
JollyAssembler >> data: aByteArray [
	"Inject data in the bytecode.
	"
	BPDataZone new
		byteArray: (aByteArray forAssembler: self);
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> decrement: byteToIncrementAddress [
	self decrement: byteToIncrementAddress into: byteToIncrementAddress
]

{ #category : #instructions }
JollyAssembler >> decrement: byteToIncrementAddress into: resultAddress [
	"We rely on the overflow of the byte addition to decrement it."
	self add: byteToIncrementAddress to: 255 into: resultAddress
]

{ #category : #instructions }
JollyAssembler >> decrementWord [
	"Decrement the word formed by content of registers A (high-byte), B (middle byte), C (low byte)."
	
	| decrementAddressFinishedLabel |
	decrementAddressFinishedLabel := ('decrementWordFinished-' , UUIDGenerator next asString) asSymbol.
	
	self
		decrement: #C;
		cmp: #C with: 255 into: #ZERO;
		jumpIfNotEqual: decrementAddressFinishedLabel;
		decrement: #B;
		cmp: #B with: 255 into: #ZERO;
		jumpIfNotEqual: decrementAddressFinishedLabel;
		decrement: #A;
		label: decrementAddressFinishedLabel;
		nop "Ensure it works even if this is the last instruction of program."
]

{ #category : #instructions }
JollyAssembler >> decrementWord: address [
	self decrementWord: address into: address
]

{ #category : #instructions }
JollyAssembler >> decrementWord: address1 into: address2 [
	"Requires registers A,B,C to be consecutive in memory."
	self
		moveWordFrom: address1 to: #A;
		decrementWord;
		moveWordFrom: #A to: address2
]

{ #category : #instructions }
JollyAssembler >> increment: byteToIncrementAddress [
	self increment: byteToIncrementAddress into: byteToIncrementAddress
]

{ #category : #instructions }
JollyAssembler >> increment: byteToIncrementAddress into: resultAddress [
	self add: byteToIncrementAddress to: 1 into: resultAddress
]

{ #category : #instructions }
JollyAssembler >> incrementWord [
	"Increment the word formed by content of registers A (high-byte), B (middle byte), C (low byte)."
	
	| incrementAddressFinishedLabel |
	incrementAddressFinishedLabel := ('incrementWordFinished-' , UUIDGenerator next asString) asSymbol.
	
	self
		increment: #C;
		cmp: #C with: 0 into: #ZERO;
		jumpIfNotEqual: incrementAddressFinishedLabel;
		increment: #B;
		cmp: #B with: 0 into: #ZERO;
		jumpIfNotEqual: incrementAddressFinishedLabel;
		increment: #A;
		label: incrementAddressFinishedLabel;
		nop "Ensure it works even if this is the last instruction of program."
]

{ #category : #instructions }
JollyAssembler >> incrementWord: address [
	"Requires registers A,B,C to be consecutive in memory."
	self incrementWord: address into: address
]

{ #category : #instructions }
JollyAssembler >> incrementWord: address1 into: address2 [
	"Requires registers A,B,C to be consecutive in memory."
	self
		moveWordFrom: address1 to: #A;
		incrementWord;
		moveWordFrom: #A to: address2
]

{ #category : #instructions }
JollyAssembler >> jump: address [
	"Let the instruction pointer do a unconditional jump to the defined address.

	 JMP address
	"
	BPJump new
		address: address;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> jumpIfEqual: address [
	"Let the instruction pointer do a jump to the defined address if ZERO flag is TRUE.
	"
	BPJumpIfEqual new
		address: address;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> jumpIfNotEqual: address [
	"Let the instruction pointer do a jump to the defined address if ZERO flag is FALSE.
	"
	BPJumpIfNotEqual new
		address: address;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> jumpIndirect: address [
	"Let the instruction pointer do a unconditional jump to the defined address.

	 JMP address
	"
	BPJumpIndirect new
		address: address;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> lookupBank: bankStartAddress from: fromAddress1 from: fromAddress2 to: toAddress [
	JollyLookupBank new
		bankStartAddress: (bankStartAddress forAssembler: self);
		firstByteToLookupAddress: (fromAddress1 forAssembler: self);
		secondByteToLookupAddress: (fromAddress2 forAssembler: self);
		resultAddress: (toAddress forAssembler: self);
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> lookupPage: pageStartAddress from: fromAddress to: toAddress [
	JollyLookupPage new
		pageStartAddress: (pageStartAddress forAssembler: self);
		byteToLookupAddress: (fromAddress forAssembler: self);
		resultAddress: (toAddress forAssembler: self);
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveCharFrom: fromAddress to: toAddress [
	"Copies the byte at fromAddress to toAddress."
	JollyMove new
		sourceDataAccess: (fromAddress forAssembler: self) asDirectAccess;
		targetDataAccess: (toAddress forAssembler: self) asDirectAccess;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveCharFrom: fromAddress toIndirect: toAddress [
	"Copies the byte at fromAddress to the address pointed by the three
	 consecutive bytes starting at toAddress.
	"
	JollyMove new
		sourceDataAccess: (fromAddress forAssembler: self) asDirectAccess;
		targetDataAccess: (toAddress forAssembler: self) asIndirectAccess;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveCharFromIndirect: fromAddress to: toAddress [
	"Copies the byte at address pointed by the three consecutive bytes starting at
	 fromAddress to toAddress.
	"
	JollyMove new
		sourceDataAccess: (fromAddress forAssembler: self) asIndirectAccess;
		targetDataAccess: (toAddress forAssembler: self) asDirectAccess;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveCharFromIndirect: fromAddress toIndirect: toAddress [
	"Copies the byte at address pointed by the three consecutive bytes starting at
	 fromAddress to the address pointed by the three consecutive bytes starting at
	 toAddress.
	"
	JollyMove new
		sourceDataAccess: (fromAddress forAssembler: self) asIndirectAccess;
		targetDataAccess: (toAddress forAssembler: self) asIndirectAccess;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveWordFrom: fromAddress to: intoAddress [
	"Copies the word (3 bytes) stored at
		fromAddress, fromAddress+1 and fromAddress+2
	 to
		toAddress, toAddress+1 and toAddress+2.
	"
	self
		moveCharFrom: (fromAddress forAssembler: self) to: (intoAddress forAssembler: self);
		moveCharFrom: (fromAddress forAssembler: self) + 1 to: (intoAddress forAssembler: self) + 1;
		moveCharFrom: (fromAddress forAssembler: self) + 2 to: (intoAddress forAssembler: self) + 2
]

{ #category : #instructions }
JollyAssembler >> moveWordFrom: fromAddress toIndirect: intoAddress [
	self moveCharFrom: (fromAddress forAssembler: self) toIndirect: (intoAddress forAssembler: self).
	self incrementWord: (intoAddress forAssembler: self).
	self moveCharFrom: (fromAddress forAssembler: self) + 1 toIndirect: (intoAddress forAssembler: self).
	self incrementWord: (intoAddress forAssembler: self).
	self moveCharFrom: (fromAddress forAssembler: self) + 2 toIndirect: (intoAddress forAssembler: self).
	self decrementWord: (intoAddress forAssembler: self).
	self decrementWord: (intoAddress forAssembler: self).
]

{ #category : #instructions }
JollyAssembler >> moveWordFromIndirect: fromAddress to: intoAddress [
	self moveCharFromIndirect: (fromAddress forAssembler: self) to: (intoAddress forAssembler: self).
	self incrementWord: (fromAddress forAssembler: self).
	self moveCharFromIndirect: (fromAddress forAssembler: self) to: (intoAddress forAssembler: self) + 1.
	self incrementWord: (fromAddress forAssembler: self).
	self moveCharFromIndirect: (fromAddress forAssembler: self) to: (intoAddress forAssembler: self) + 2.
	self decrementWord: (fromAddress forAssembler: self).
	self decrementWord: (fromAddress forAssembler: self).
]

{ #category : #instructions }
JollyAssembler >> moveWordFromIndirect: fromAddress toIndirect: intoAddress [
	self moveCharFrom: (fromAddress forAssembler: self) toIndirect: (intoAddress forAssembler: self).
	self incrementWord: (fromAddress forAssembler: self).
	self incrementWord: (intoAddress forAssembler: self).
	self moveCharFrom: (fromAddress forAssembler: self) toIndirect: (intoAddress forAssembler: self).
	self incrementWord: (fromAddress forAssembler: self).
	self incrementWord: (intoAddress forAssembler: self).
	self moveCharFrom: (fromAddress forAssembler: self) toIndirect: (intoAddress forAssembler: self).
	self decrementWord: (fromAddress forAssembler: self).
	self decrementWord: (fromAddress forAssembler: self).
	self decrementWord: (intoAddress forAssembler: self).
	self decrementWord: (intoAddress forAssembler: self).
]

{ #category : #instructions }
JollyAssembler >> nop [
	"No-op instruction, does nothing.
	"
	BPNop new
		generateFor: self
]
