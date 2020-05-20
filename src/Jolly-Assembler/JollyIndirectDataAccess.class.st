Class {
	#name : #JollyIndirectDataAccess,
	#superclass : #JollyDataAccess,
	#category : #'Jolly-Assembler'
}

{ #category : #generating }
JollyIndirectDataAccess >> generateSourceAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: anAssemblerInstruction [
	| highByteAddressCopyInstruction middleByteAddressCopyInstruction lowByteAddressCopyInstruction |
	highByteAddressCopyInstruction := anAssemblerInstruction newInstruction.
	middleByteAddressCopyInstruction := anAssemblerInstruction newInstruction.
	lowByteAddressCopyInstruction := anAssemblerInstruction newInstruction.
	highByteAddressCopyInstruction
		beAddedTo: anAssembler;
		from: self address;
		to: lastInstruction asReference fromAddressHighByte;
		jump: middleByteAddressCopyInstruction asReference.
	middleByteAddressCopyInstruction
		beAddedTo: anAssembler;
		from: self address + 1;
		to: lastInstruction asReference fromAddressMiddleByte;
		jump: lowByteAddressCopyInstruction asReference.
	lowByteAddressCopyInstruction
		beAddedTo: anAssembler;
		from: self address + 2;
		to: lastInstruction asReference fromAddressLowByte;
		jump: BPNextInstructionReference new
]

{ #category : #generating }
JollyIndirectDataAccess >> generateTargetAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: anAssemblerInstruction [
	| highByteAddressCopyInstruction middleByteAddressCopyInstruction lowByteAddressCopyInstruction |
	highByteAddressCopyInstruction := anAssemblerInstruction newInstruction.
	middleByteAddressCopyInstruction := anAssemblerInstruction newInstruction.
	lowByteAddressCopyInstruction := anAssemblerInstruction newInstruction.
	highByteAddressCopyInstruction
		beAddedTo: anAssembler;
		from: self address;
		to: lastInstruction asReference toAddressHighByte;
		jump: middleByteAddressCopyInstruction asReference.
	middleByteAddressCopyInstruction
		beAddedTo: anAssembler;
		from: self address + 1;
		to: lastInstruction asReference toAddressMiddleByte;
		jump: lowByteAddressCopyInstruction asReference.
	lowByteAddressCopyInstruction
		beAddedTo: anAssembler;
		from: self address + 2;
		to: lastInstruction asReference toAddressLowByte;
		jump: BPNextInstructionReference new
]
