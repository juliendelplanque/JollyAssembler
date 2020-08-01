"
I am an abstract announcement concerning the execution of a Jolly VM.
"
Class {
	#name : #JollyAboutToExecuteInstruction,
	#superclass : #Announcement,
	#instVars : [
		'virtualMachine',
		'instructionAddress'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #'instance creation' }
JollyAboutToExecuteInstruction class >> vm: aVirtualMachine address: instructionAddress [
	^ self new
		virtualMachine: aVirtualMachine;
		instructionAddress: instructionAddress;
		yourself
]

{ #category : #accessing }
JollyAboutToExecuteInstruction >> instructionAddress [
	^ instructionAddress
]

{ #category : #accessing }
JollyAboutToExecuteInstruction >> instructionAddress: anObject [
	instructionAddress := anObject
]

{ #category : #accessing }
JollyAboutToExecuteInstruction >> virtualMachine [
	^ virtualMachine
]

{ #category : #accessing }
JollyAboutToExecuteInstruction >> virtualMachine: anObject [
	virtualMachine := anObject
]
