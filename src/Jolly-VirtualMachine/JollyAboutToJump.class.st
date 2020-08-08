"
I announce the fact that a Jolly Virtual Machine is about to jump to an address.
That is to say, the program counter of the virtual machine will be modified to #jumpAddress.
"
Class {
	#name : #JollyAboutToJump,
	#superclass : #JollyAboutToExecuteInstruction,
	#instVars : [
		'jumpAddress'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #'instance creation' }
JollyAboutToJump class >> vm: aVirtualMachine address: instructionAddress jump: jumpAddress [
	^ self new
		virtualMachine: aVirtualMachine;
		instructionAddress: instructionAddress;
		jumpAddress: jumpAddress;
		yourself
]

{ #category : #accessing }
JollyAboutToJump >> jumpAddress [
	^ jumpAddress
]

{ #category : #accessing }
JollyAboutToJump >> jumpAddress: anObject [
	jumpAddress := anObject
]

{ #category : #printing }
JollyAboutToJump >> printOn: aStream [
	aStream nextPutAll: 'JUMP memory['.
	aStream nextPutAll: (self jumpAddress printPaddedWith: $0 to: 6 base: 16).
	aStream nextPut: $]
]
