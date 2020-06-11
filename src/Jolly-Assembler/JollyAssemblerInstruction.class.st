Class {
	#name : #JollyAssemblerInstruction,
	#superclass : #BPAssemblerInstruction,
	#category : #'Jolly-Assembler'
}

{ #category : #accessing }
JollyAssemblerInstruction >> tag [
	^ self className allButFirst: 'Jolly' size
]
