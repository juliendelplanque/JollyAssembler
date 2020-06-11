Class {
	#name : #JollyLookupBank,
	#superclass : #JollyAssemblerInstruction,
	#instVars : [
		'resultAddress',
		'firstByteToLookupAddress',
		'secondByteToLookupAddress',
		'bankStartAddress'
	],
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyLookupBank >> bankStartAddress [
	^ bankStartAddress
]

{ #category : #accessing }
JollyLookupBank >> bankStartAddress: anObject [
	bankStartAddress := anObject
]

{ #category : #accessing }
JollyLookupBank >> firstByteToLookupAddress [
	^ firstByteToLookupAddress
]

{ #category : #accessing }
JollyLookupBank >> firstByteToLookupAddress: anObject [
	firstByteToLookupAddress := anObject
]

{ #category : #generating }
JollyLookupBank >> generateFor: anAssembler [
	| instruction1 instruction2 instruction3 |
	instruction1 := self newInstruction
		from: self firstByteToLookupAddress;
		beAddedTo: anAssembler;
		yourself.
	
	instruction2 := self newInstruction
		from: self secondByteToLookupAddress;
		beAddedTo: anAssembler;
		yourself.
		
	instruction3 := self newInstruction
		from: self bankStartAddress;
		to: self resultAddress;
		beAddedTo: anAssembler;
		yourself.
		
	instruction1
		jump: instruction2 asReference;
		to: instruction3 asReference fromAddressMiddleByte.
	
	instruction2
		jump: instruction3 asReference;
		to: instruction3 asReference fromAddressLowByte.
		
	instruction3
		jump: BPNextInstructionReference new
]

{ #category : #accessing }
JollyLookupBank >> resultAddress [
	^ resultAddress
]

{ #category : #accessing }
JollyLookupBank >> resultAddress: anObject [
	resultAddress := anObject
]

{ #category : #accessing }
JollyLookupBank >> secondByteToLookupAddress [
	^ secondByteToLookupAddress
]

{ #category : #accessing }
JollyLookupBank >> secondByteToLookupAddress: anObject [
	secondByteToLookupAddress := anObject
]
