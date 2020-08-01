Class {
	#name : #JollyAboutToExecutePrimitive,
	#superclass : #JollyAboutToExecuteInstruction,
	#instVars : [
		'primitiveId',
		'resultsAddress'
	],
	#category : #'Jolly-VirtualMachine'
}

{ #category : #'instance creation' }
JollyAboutToExecutePrimitive class >> vm: aVirtualMachine address: instructionAddress primitiveId: primitiveId resultsAddress: resultsAddress [
	^ self new
		virtualMachine: aVirtualMachine;
		instructionAddress: instructionAddress;
		primitiveId: primitiveId;
		resultsAddress: resultsAddress;
		yourself
]

{ #category : #accessing }
JollyAboutToExecutePrimitive >> primitiveId [
	^ primitiveId
]

{ #category : #accessing }
JollyAboutToExecutePrimitive >> primitiveId: anObject [
	primitiveId := anObject
]

{ #category : #accessing }
JollyAboutToExecutePrimitive >> resultsAddress [
	^ resultsAddress
]

{ #category : #accessing }
JollyAboutToExecutePrimitive >> resultsAddress: anObject [
	resultsAddress := anObject
]
