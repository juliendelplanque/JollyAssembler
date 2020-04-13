Class {
	#name : #JollyMemoryLayoutV1,
	#superclass : #BPMemoryLayout,
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyMemoryLayoutV1 >> endAddress [
	^ 16rFFFFFF
]

{ #category : #initialization }
JollyMemoryLayoutV1 >> initialize [
	| available_memory_start |
	super initialize.
	available_memory_start := 9.
	self
		name: 'JollyV1';
		addAll: {
		BPReservedMemoryZone name: #PROGRAM_COUNTER startAddress: 0 size: 2.
		BPRegister name: #PRIMITIVE_IS_READY address: 3.
		BPRegister name: #PRIMITIVE_CALL_ID address: 4.
		BPRegister name: #PRIMITIVE_RESULT_CODE address: 5.
		BPRegister name: #PRIMITIVE_RESULT_HIGH address: 6.
		BPRegister name: #PRIMITIVE_RESULT_MIDDLE address: 7.
		BPRegister name: #PRIMITIVE_RESULT_LOW address: 8.
		BPRegister name: #A address: available_memory_start.
		BPRegister name: #B address: available_memory_start + 1.
		BPRegister name: #C address: available_memory_start + 2.
		BPRegister name: #SP address: available_memory_start + 3.
		BPRegister name: #CARRY address: available_memory_start + 4.
		BPRegister name: #ZERO address: available_memory_start + 5.
		BPRegister name: #RETURN_SP address: available_memory_start + 6.
		BPReservedMemoryZone name: #JUMP_IF_ZERO startAddress: available_memory_start + 7 size: INSTRUCTION_SIZE.
		BPReservedMemoryZone name: #JUMP_IF_NONZERO startAddress: available_memory_start + 7 + INSTRUCTION_SIZE size: INSTRUCTION_SIZE.
		BPRegister name: #D address: available_memory_start + 7 + (2*INSTRUCTION_SIZE).
		BPRegister name: #E address: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 1.
		BPRegister name: #F address: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 2.
		BPRegister name: #G address: available_memory_start + 7 + (2*INSTRUCTION_SIZE) + 3.
		BPAddBankBuilder reservedMemoryZoneStartingAt: 16r10000.
		BPAddZeroFlagBankBuilder reservedMemoryZoneStartingAt: 16r20000.
		BPAddCarryFlagBankBuilder reservedMemoryZoneStartingAt: 16r50000.
		BPCmpBankBuilder reservedMemoryZoneStartingAt: 16r30000.
		BPBitAndBankBuilder reservedMemoryZoneStartingAt: 16r80000.
		BPIdentityPageBuilder reservedMemoryZoneStartingAt: 16r40000.
		BPIncrementPageBuilder reservedMemoryZoneStartingAt: 16r40100.
		BPDecrementPageBuilder reservedMemoryZoneStartingAt: 16r40200.
		BPReservedMemoryZone name: #DATA_STACK startAddress: 16r40300 size: 16rFF.
		BPReservedMemoryZone name: #RETURN_STACK startAddress: 16r40400 size: 16rFF }
]
