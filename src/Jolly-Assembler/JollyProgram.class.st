Class {
	#name : #JollyProgram,
	#superclass : #Object,
	#category : #'Jolly-Assembler'
}

{ #category : #generating }
JollyProgram >> generate [
	| assembler |
	assembler := JollyAssembler new.
	self generateOn: assembler.
	^ assembler
]

{ #category : #writing }
JollyProgram >> writeOn: fileReference [
	fileReference binaryWriteStreamDo: [ :s |
		|assembledCode memory|
		assembledCode := self generate assemble.
		memory := ByteArray new: assembledCode instructions last endAddress memoryAddress.
		assembledCode serializeOn: memory.
		s nextPutAll: memory ]
]
