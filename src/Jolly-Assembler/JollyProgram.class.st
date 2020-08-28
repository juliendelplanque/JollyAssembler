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

{ #category : #generating }
JollyProgram >> generateOn: assembler [
	self subclassResponsibility
]

{ #category : #writing }
JollyProgram >> writeOn: fileReference [
	|assembledCode|
	assembledCode := self generate assemble.
	fileReference binaryWriteStreamDo: [ :s |
		|memory|
		memory := ByteArray new: assembledCode instructions last endAddress memoryAddress.
		assembledCode serializeOn: memory.
		s nextPutAll: memory ].
	(fileReference , 'meta') ensureDelete;
		writeStreamDo: [ :s |
			assembledCode labels do: [ :label |
				s nextPutAll: label label.
				s nextPut: $,.
				s nextPutAll: '0x'.
				s nextPutAll: label address hex.
				s nextPutAll: Smalltalk os lineEnding ]  ]
]
