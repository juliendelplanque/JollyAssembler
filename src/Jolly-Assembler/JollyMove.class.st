Class {
	#name : #JollyMove,
	#superclass : #BPAssemblerInstruction,
	#instVars : [
		'sourceDataAccess',
		'targetDataAccess'
	],
	#category : #'Jolly-Assembler'
}

{ #category : #generating }
JollyMove >> generateFor: anAssembler [
	| lastInstruction |
	lastInstruction := self newInstruction.
	
	lastInstruction
		from: 0 asBPAddress;
		to: 0 asBPAddress.
	
	self sourceDataAccess
		generateSourceAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: self.
		
	self targetDataAccess
		generateTargetAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: self.
		
	lastInstruction
		jump: BPNextInstructionReference new;
		beAddedTo: anAssembler
]

{ #category : #accessing }
JollyMove >> sourceDataAccess [
	^ sourceDataAccess
]

{ #category : #accessing }
JollyMove >> sourceDataAccess: anObject [
	sourceDataAccess := anObject
]

{ #category : #accessing }
JollyMove >> tag [
	^ self className allButFirst: 'Jolly' size
]

{ #category : #accessing }
JollyMove >> targetDataAccess [
	^ targetDataAccess
]

{ #category : #accessing }
JollyMove >> targetDataAccess: anObject [
	targetDataAccess := anObject
]
