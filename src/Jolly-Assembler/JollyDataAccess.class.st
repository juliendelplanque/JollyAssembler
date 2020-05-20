Class {
	#name : #JollyDataAccess,
	#superclass : #Object,
	#instVars : [
		'address'
	],
	#category : #'Jolly-Assembler'
}

{ #category : #'instance creation' }
JollyDataAccess class >> address: address [
	<generated>
	^ self new
		address: address;
		yourself
]

{ #category : #accessing }
JollyDataAccess >> address [
	^ address
]

{ #category : #accessing }
JollyDataAccess >> address: anObject [
	address := anObject
]

{ #category : #generating }
JollyDataAccess >> generateSourceAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: anAssemblerInstruction [
	self subclassResponsibility
]

{ #category : #generating }
JollyDataAccess >> generateTargetAccessFor: anAssembler withInstruction: lastInstruction assemblerInstruction: anAssemblerInstruction [
	self subclassResponsibility
]
