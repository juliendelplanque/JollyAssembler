"
I announce the fact that a Jolly Virtual Machine is about to copy a byte from an address to another.
That is to say, byte stored at #toAddress will be identical to the byte stored at #fromAddress after the copy.
"
Class {
	#name : #JollyAboutToMoveByte,
	#superclass : #JollyAboutToExecuteInstruction,
	#instVars : [
		'fromAddress',
		'toAddress'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #'instance creation' }
JollyAboutToMoveByte class >> vm: aVirtualMachine address: instructionAddress from: fromAddress to: toAddress [
	^ self new
		virtualMachine: aVirtualMachine;
		instructionAddress: instructionAddress;
		fromAddress: fromAddress;
		toAddress: toAddress;
		yourself
]

{ #category : #accessing }
JollyAboutToMoveByte >> fromAddress [
	^ fromAddress
]

{ #category : #accessing }
JollyAboutToMoveByte >> fromAddress: anObject [
	fromAddress := anObject
]

{ #category : #accessing }
JollyAboutToMoveByte >> toAddress [
	^ toAddress
]

{ #category : #accessing }
JollyAboutToMoveByte >> toAddress: anObject [
	toAddress := anObject
]
