"
A JollyAssemblerTest is a test class for testing the behavior of JollyAssembler
"
Class {
	#name : #JollyAssemblerTest,
	#superclass : #TestCase,
	#category : #'Jolly-Assembler-Tests'
}

{ #category : #test }
JollyAssemblerTest >> testMoveCharFromIndirectTo [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForFrom;
		data: (assembly memoryLayout registerNamed: #A) address asByteArray;
		label: #endData;
		moveCharFrom: 5 to: #A;
		moveCharFrom: 0 to: #B;
		moveCharFromIndirect: #addressForFrom to: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	8 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 5.
]

{ #category : #test }
JollyAssemblerTest >> testMoveCharFromIndirectToIndirect [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForFrom;
		data: (assembly memoryLayout registerNamed: #A) address asByteArray;
		label: #addressForTo;
		data: (assembly memoryLayout registerNamed: #B) address asByteArray;
		label: #endData;
		moveCharFrom: 5 to: #A;
		moveCharFrom: 0 to: #B;
		moveCharFromIndirect: #addressForFrom toIndirect: #addressForTo.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	12 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 5.
]

{ #category : #test }
JollyAssemblerTest >> testMoveCharFromTo [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 6 to: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	2 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 6.
]

{ #category : #test }
JollyAssemblerTest >> testMoveCharFromToIndirect [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForTo;
		data: (assembly memoryLayout registerNamed: #B) address asByteArray;
		label: #endData;
		moveCharFrom: 5 to: #A;
		moveCharFrom: 0 to: #B;
		moveCharFrom: #A toIndirect: #addressForTo.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	8 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 5.
]

{ #category : #test }
JollyAssemblerTest >> testMoveWordFromTo [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #wordToMove;
		data: #[1 2 3];
		label: #targetForWordMove;
		data: #[0 0 0];
		label: #endData;
		moveWordFrom: #wordToMove to: #targetForWordMove.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	4 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #wordToMove) address access: memory) equals: 1.
	self assert: ((assembledCode labelNamed: #wordToMove) address + 1 access: memory) equals: 2.
	self assert: ((assembledCode labelNamed: #wordToMove) address + 2 access: memory) equals: 3.
	
	self assert: ((assembledCode labelNamed: #targetForWordMove) address access: memory) equals: 1.
	self assert: ((assembledCode labelNamed: #targetForWordMove) address + 1 access: memory) equals: 2.
	self assert: ((assembledCode labelNamed: #targetForWordMove) address + 2 access: memory) equals: 3.
]
