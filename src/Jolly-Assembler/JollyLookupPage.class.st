Class {
	#name : #JollyLookupPage,
	#superclass : #JollyAssemblerInstruction,
	#instVars : [
		'byteToLookupAddress',
		'pageStartAddress',
		'resultAddress'
	],
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyLookupPage >> byteToLookupAddress [
	^ byteToLookupAddress
]

{ #category : #accessing }
JollyLookupPage >> byteToLookupAddress: anObject [
	byteToLookupAddress := anObject
]

{ #category : #generating }
JollyLookupPage >> generateFor: anAssembler [
	| instruction1 instruction2 |
	instruction1 := self newInstruction
		from: self byteToLookupAddress;
		beAddedTo: anAssembler;
		yourself.
		
	instruction2 := self newInstruction
		from: self pageStartAddress;
		to: self resultAddress;
		beAddedTo: anAssembler;
		yourself.
		
	instruction1
		jump: instruction2 asReference;
		to: instruction2 asReference fromAddressLowByte.
		
	instruction2
		jump: BPNextInstructionReference new
]

{ #category : #accessing }
JollyLookupPage >> pageStartAddress [
	^ pageStartAddress
]

{ #category : #accessing }
JollyLookupPage >> pageStartAddress: anObject [
	pageStartAddress := anObject
]

{ #category : #accessing }
JollyLookupPage >> resultAddress [
	^ resultAddress
]

{ #category : #accessing }
JollyLookupPage >> resultAddress: anObject [
	resultAddress := anObject
]
