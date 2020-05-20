Class {
	#name : #JollyDirectDataAccess,
	#superclass : #JollyDataAccess,
	#category : #'Jolly-Assembler'
}

{ #category : #generating }
JollyDirectDataAccess >> generateSourceAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: anAssemblerInstruction [
	lastInstruction
		from: self address
]

{ #category : #generating }
JollyDirectDataAccess >> generateTargetAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: anAssemblerInstruction [
	lastInstruction
		to: self address
]
