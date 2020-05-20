Class {
	#name : #JollyAssembler,
	#superclass : #BPAbstractAssembler,
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyAssembler class >> defaultMemoryLayout [
	^ JollyMemoryLayoutV1 new
]

{ #category : #assembling }
JollyAssembler >> assemble [
	self flag: #TODO. "Manage this more cleanly."
	self instructions last jump class = BPNextInstructionReference
		ifTrue: [ self instructions last jump: 0 asBPAddress ].
	^ super assemble
]

{ #category : #'instructions-backup' }
JollyAssembler >> loadCharInto: targetAddress fromHigh: highAddressByteAddress middle: middleAddressByteAddress low: lowAddressByteAddress [
	"Loads the character pointed by the address formed by highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress
	 into byte at targetAddress.
	
	 For example, if
		targetAddress            = 16r000042
		highAddressByteAddress   = 16r000001
		middleAddressByteAddress = 16r000002
		lowAddressByteAddress    = 16r000003
	 Considering that memory is in following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 10
		...
		memory[16r000143] = 11
		...
	
	 The bytecodes generated copy the character at address 16r000143 into byte at address 16r000042 leading memory to the following
	 state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 11
		...
		memory[16r000143] = 11
		...
	"
	self flag: #TODO; halt
]

{ #category : #'instructions-backup' }
JollyAssembler >> loadWordInto: targetAddress fromHigh: highAddressByteAddress middle: middleAddressByteAddress low: lowAddressByteAddress [
	"Loads the word (3 bytes) pointed by the address formed by (highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress),
	 (highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress) + 1 and (highAddressByteAddress, middleAddressByteAddress
	 and lowAddressByteAddress) + 2 into the 3 bytes at targetAddress, targetAddress+1 and targetAddress+2.
	
	 For example, if
		targetAddress            = 16r424344
		highAddressByteAddress   = 16r000001
		middleAddressByteAddress = 16r000002
		lowAddressByteAddress    = 16r000003
	 Considering that memory is in following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000143] = 11
		memory[16r000144] = 11
		memory[16r000145] = 11
		...
		memory[16r424344] = 10
		memory[16r424345] = 10
		memory[16r424346] = 10
		...
	
	 The bytecodes generated
		- copy the character at address 16r000143 into byte at address 16r000042
		- copy the character at address 16r000144 into byte at address 16r000043
		- copy the character at address 16r000145 into byte at address 16r000044
	
	 leading memory to the following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000143] = 11
		memory[16r000144] = 11
		memory[16r000145] = 11
		...
		memory[16r424344] = 11
		memory[16r424345] = 11
		memory[16r424346] = 11
		...
	"
	self flag: #TODO; halt
]

{ #category : #'instructions-backup' }
JollyAssembler >> loadWordIntoHigh: highTargetAddress middle: middleTargetAddress low: lowTargetAddress fromHigh: highAddressByteAddress middle: middleAddressByteAddress low: lowAddressByteAddress [
	"Loads the word (3 bytes) pointed by the address formed by (highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress),
	 (highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress) + 1 and (highAddressByteAddress, middleAddressByteAddress
	 and lowAddressByteAddress) + 2 into the 3 bytes at highTargetAddress, middleTargetAddress and lowTargetAddress.
	
	 For example, if
		highTargetAddress        = 16r000042
		middleTargetAddress      = 16r000043
		lowTargetAddress         = 16r000044
		highAddressByteAddress   = 16r000001
		middleAddressByteAddress = 16r000002
		lowAddressByteAddress    = 16r000003
	 Considering that memory is in following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 10
		memory[16r000043] = 10
		memory[16r000044] = 10
		...
		memory[16r000143] = 11
		memory[16r000144] = 11
		memory[16r000145] = 11
		...
	
	 The bytecodes generated
		- copy the character at address 16r000143 into byte at address 16r000042
		- copy the character at address 16r000144 into byte at address 16r000043
		- copy the character at address 16r000145 into byte at address 16r000044
	
	 leading memory to the following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 11
		memory[16r000043] = 11
		memory[16r000044] = 11
		...
		memory[16r000143] = 11
		memory[16r000144] = 11
		memory[16r000145] = 11
		...
	"
	self flag: #TODO; halt
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
		source: (fromAddress forAssembler: self) asDirectAccess;
		target: (toAddress forAssembler: self) asIndirectAccess;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveCharFromIndirect: fromAddress to: toAddress [
	"Copies the byte at address pointed by the three consecutive bytes starting at
	 fromAddress to toAddress.
	"
	JollyMove new
		source: (fromAddress forAssembler: self) asIndirectAccess;
		target: (toAddress forAssembler: self) asDirectAccess;
		generateFor: self
]

{ #category : #instructions }
JollyAssembler >> moveCharFromIndirect: fromAddress toIndirect: toAddress [
	"Copies the byte at address pointed by the three consecutive bytes starting at
	 fromAddress to the address pointed by the three consecutive bytes starting at
	 toAddress.
	"
	JollyMove new
		source: (fromAddress forAssembler: self) asIndirectAccess;
		target: (toAddress forAssembler: self) asIndirectAccess;
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
		moveCharFrom: fromAddress to: intoAddress;
		moveCharFrom: fromAddress + 1 to: intoAddress + 1;
		moveCharFrom: fromAddress + 2 to: intoAddress + 2
]

{ #category : #instructions }
JollyAssembler >> moveWordFrom: fromAddress toIndirect: intoAddress [
	self flag: #TODO; halt
]

{ #category : #instructions }
JollyAssembler >> moveWordFromIndirect: fromAddress to: intoAddress [
	self flag: #TODO; halt
]

{ #category : #instructions }
JollyAssembler >> moveWordFromIndirect: fromAddress toIndirect: intoAddress [
	self flag: #TODO; halt
]

{ #category : #'instructions-backup' }
JollyAssembler >> storeCharAt: sourceAddress intoHigh: highAddressByteAddress middle: middleAddressByteAddress low: lowAddressByteAddress [
	"Stores the character stored at sourceAddress into the byte pointed by the address formed by highAddressByteAddress,
	middleAddressByteAddress and lowAddressByteAddress.
	
	 For example, if
		sourceAddress            = 16r000042
		highAddressByteAddress   = 16r000001
		middleAddressByteAddress = 16r000002
		lowAddressByteAddress    = 16r000003
	 Considering that memory is in following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 10
		...
		memory[16r000143] = 11
		...
	
	 The bytecodes generated copy the character at address16r000042 into byte at address 16r000143 leading memory to the following
	 state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 10
		...
		memory[16r000143] = 10
		...
	"
	self flag: #TODO; halt
]

{ #category : #'instructions-backup' }
JollyAssembler >> storeWordAtHigh: highSourceAddress middle: middleSourceAddress low: lowSourceAddress intoHigh: highAddressByteAddress middle: middleAddressByteAddress low: lowAddressByteAddress [
	"Stores the word (3 bytes) pointed by the 3 bytes at highTargetAddress, middleTargetAddress and lowTargetAddress into the bytes
	 pointed by the addresss formed by (highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress),
	 (highAddressByteAddress, middleAddressByteAddress and lowAddressByteAddress) + 1 and (highAddressByteAddress, middleAddressByteAddress
	 and lowAddressByteAddress) + 2.
	
	 For example, if
		highTargetAddress        = 16r000042
		middleTargetAddress      = 16r000043
		lowTargetAddress         = 16r000044
		highAddressByteAddress   = 16r000001
		middleAddressByteAddress = 16r000002
		lowAddressByteAddress    = 16r000003
	 Considering that memory is in following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 10
		memory[16r000043] = 10
		memory[16r000044] = 10
		...
		memory[16r000143] = 11
		memory[16r000144] = 11
		memory[16r000145] = 11
		...
	
	 The bytecodes generated
		- copy the character at address 16r000042 into byte at address 16r000143
		- copy the character at address 16r000043 into byte at address 16r000144
		- copy the character at address 16r000044 into byte at address 16r000145
	
	 leading memory to the following state:
		...
		memory[16r000001] = 0
		memory[16r000002] = 1
		memory[16r000003] = 43
		...
		memory[16r000042] = 11
		memory[16r000043] = 11
		memory[16r000044] = 11
		...
		memory[16r000143] = 10
		memory[16r000144] = 10
		memory[16r000145] = 10
		...
	"
	self flag: #TODO; halt
]
