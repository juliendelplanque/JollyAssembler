Class {
	#name : #JollyEForth,
	#superclass : #Object,
	#category : #'Jolly-EForth'
}

{ #category : #generating }
JollyEForth class >> generateOn: assembly [
	^ self new
		generateOn: assembly;
		yourself
]

{ #category : #including }
JollyEForth >> beIncludedTo: assembler [
	self generateOn: assembler
]

{ #category : #generating }
JollyEForth >> generateOn: assembly [
	self shouldBeImplemented
]
