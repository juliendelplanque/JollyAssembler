Class {
	#name : #JollyMemoryLayoutV1,
	#superclass : #BPMemoryLayout,
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyMemoryLayoutV1 >> endAddress [
	^ 16rFFFFFF asBPAddress
]

{ #category : #initialization }
JollyMemoryLayoutV1 >> initialize [
	| available_memory_start |
	super initialize.
	available_memory_start := 9.
	self
		name: 'JollyV1';
		addAll: {
		BPReservedMemoryZone name: #PROGRAM_COUNTER startAddress: 0 size: 3.
		BPRegister name: #PRIMITIVE_IS_READY address: 3.
		BPRegister name: #PRIMITIVE_CALL_ID address: 4.
		BPRegister name: #PRIMITIVE_RESULT_CODE address: 5.
		BPRegister name: #PRIMITIVE_RESULT_HIGH address: 6.
		BPRegister name: #PRIMITIVE_RESULT_MIDDLE address: 7.
		BPRegister name: #PRIMITIVE_RESULT_LOW address: 8.
		BPRegister name: #A address: available_memory_start.
		BPRegister name: #B address: available_memory_start + 1.
		BPRegister name: #C address: available_memory_start + 2.
		BPRegister name: #D address: available_memory_start + 3.
		BPRegister name: #CARRY address: available_memory_start + 4.
		BPRegister name: #ZERO address: available_memory_start + 5.
		BPRegister name: #E address: available_memory_start + 6.
		BPReservedMemoryZone name: #JUMP_IF_ZERO startAddress: available_memory_start + 7 size: INSTRUCTION_SIZE.
		BPReservedMemoryZone name: #JUMP_IF_NONZERO startAddress: available_memory_start + 7 + INSTRUCTION_SIZE size: INSTRUCTION_SIZE.
		BPRegister name: #F address: available_memory_start + 7 + (2*INSTRUCTION_SIZE).
		BPRegister name: #G address: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 1.
		BPRegister name: #H address: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 2.
		BPRegister name: #I address: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 3.
		BPReservedMemoryZone name: #SP startAddress: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 4 size: ADDRESS_SIZE.
		BPReservedMemoryZone name: #RP startAddress: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 4 + ADDRESS_SIZE size: ADDRESS_SIZE.
		BPAddBankBuilder reservedMemoryZoneStartingAt: 16r10000.
		BPAddZeroFlagBankBuilder reservedMemoryZoneStartingAt: 16r20000.
		BPCmpBankBuilder reservedMemoryZoneStartingAt: 16r30000.
		BPIdentityPageBuilder reservedMemoryZoneStartingAt: 16r40000.
		BPIncrementPageBuilder reservedMemoryZoneStartingAt: 16r40100.
		BPDecrementPageBuilder reservedMemoryZoneStartingAt: 16r40200.
		BPAddCarryFlagBankBuilder reservedMemoryZoneStartingAt: 16r50000.
		BPReservedMemoryZone name: #DATA_STACK startAddress: 16r60000 size: 16rFFFF.
		BPReservedMemoryZone name: #RETURN_STACK startAddress: 16r70000 size: 16rFFFF.
		BPBitAndBankBuilder reservedMemoryZoneStartingAt: 16r80000. }
]

{ #category : #'initialize memory' }
JollyMemoryLayoutV1 >> initializeMemory: aByteArray [
	super initializeMemory: aByteArray.
	(self reservedMemoryZoneNamed: #SP) address
		storeInteger: (self reservedMemoryZoneNamed: #DATA_STACK) startAddress memoryAddress in: aByteArray.
		
	(self reservedMemoryZoneNamed: #RP) address
		storeInteger: (self reservedMemoryZoneNamed: #RETURN_STACK) endAddress memoryAddress in: aByteArray.
]
