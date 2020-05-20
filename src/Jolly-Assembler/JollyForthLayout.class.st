Class {
	#name : #JollyForthLayout,
	#superclass : #BPMemoryLayout,
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyForthLayout >> endAddress [
	^ 16rFFFFFF asBPAddress
]

{ #category : #initialization }
JollyForthLayout >> initialize [
	| available_memory_start |
	super initialize.
	available_memory_start := 16r10.
	self
		name: 'JollyForth';
		addAll: {
		BPReservedMemoryZone name: #PROGRAM_COUNTER startAddress: 0 size: 3.
		BPRegister name: #PRIMITIVE_IS_READY address: 3.
		BPRegister name: #PRIMITIVE_CALL_ID address: 4.
		BPRegister name: #PRIMITIVE_RESULT_CODE address: 5.
		BPRegister name: #PRIMITIVE_RESULT_HIGH address: 6.
		BPRegister name: #PRIMITIVE_RESULT_MIDDLE address: 7.
		BPRegister name: #PRIMITIVE_RESULT_LOW address: 8.
		BPReservedMemoryZone name: #JUMP_IF_ZERO startAddress: available_memory_start size: INSTRUCTION_SIZE.
		BPReservedMemoryZone name: #JUMP_IF_NONZERO startAddress: available_memory_start + (INSTRUCTION_SIZE) size: INSTRUCTION_SIZE.
		BPReservedMemoryZone name: #LATEST startAddress: available_memory_start + (2*INSTRUCTION_SIZE) + 1 size: INSTRUCTION_SIZE.
		BPReservedMemoryZone name: #NEXT_WORD startAddress: available_memory_start + (3*INSTRUCTION_SIZE) + 1 size: INSTRUCTION_SIZE.
		BPReservedMemoryZone name: #ACC startAddress: available_memory_start + (4*INSTRUCTION_SIZE) + 1 size: 3.
		BPReservedMemoryZone name: #PARAMETERS_SP startAddress: available_memory_start + (5*INSTRUCTION_SIZE) + 1 size: 3.
		BPReservedMemoryZone name: #RETURN_SP startAddress: available_memory_start + (6*INSTRUCTION_SIZE) + 1 size: 3.
		BPAddBankBuilder reservedMemoryZoneStartingAt: 16r10000.
		BPAddZeroFlagBankBuilder reservedMemoryZoneStartingAt: 16r20000.
		BPCmpBankBuilder reservedMemoryZoneStartingAt: 16r30000.
		BPIdentityPageBuilder reservedMemoryZoneStartingAt: 16r40000.
		BPIncrementPageBuilder reservedMemoryZoneStartingAt: 16r40100.
		BPDecrementPageBuilder reservedMemoryZoneStartingAt: 16r40200.
		BPAddCarryFlagBankBuilder reservedMemoryZoneStartingAt: 16r50000.
		BPBitAndBankBuilder reservedMemoryZoneStartingAt: 16r60000.
		BPReservedMemoryZone name: #STACK startAddress: 16r70000 size: 16r20000.
		BPReservedMemoryZone name: #HEAP startAddress: 16r90000 size: 16r20000 }
]
