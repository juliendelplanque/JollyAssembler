Class {
	#name : #JollyConstants,
	#superclass : #SharedPool,
	#classVars : [
		'ADDRESS_SIZE',
		'FALSE_VALUE',
		'INSTRUCTION_SIZE',
		'MAX_ADDRESS',
		'MEMORY_SIZE',
		'PROGRAM_COUNTER_ADDRESS',
		'TRUE_VALUE',
		'USER_MEMORY_ADDRESS'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #'class initialization' }
JollyConstants class >> initialize [
	PROGRAM_COUNTER_ADDRESS := 0.
	USER_MEMORY_ADDRESS := 9.
	ADDRESS_SIZE := 3.
	INSTRUCTION_SIZE := ADDRESS_SIZE * 3.
	MEMORY_SIZE := 16r1000000.
	MAX_ADDRESS := MEMORY_SIZE - 1.
	FALSE_VALUE := 16r10.
	TRUE_VALUE := FALSE_VALUE + INSTRUCTION_SIZE.
]
