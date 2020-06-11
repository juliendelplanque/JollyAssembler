"
A JollyAssemblerTest is a test class for testing the behavior of JollyAssembler
"
Class {
	#name : #JollyAssemblerTest,
	#superclass : #TestCase,
	#pools : [
		'BPConstants'
	],
	#category : #'Jolly-Assembler-Tests'
}

{ #category : #test }
JollyAssemblerTest >> testCmpWith [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 5 to: #B;
		cmp: #A with: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	5 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: TRUE_VALUE.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 5.
]

{ #category : #test }
JollyAssemblerTest >> testCmpWith2 [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 4 to: #B;
		cmp: #A with: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	5 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: FALSE_VALUE.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 4.
]

{ #category : #test }
JollyAssemblerTest >> testCmpWithInto [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 5 to: #B;
		cmp: #A with: #B into: #C.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	5 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #C) valueIn: memory) equals: TRUE_VALUE
]

{ #category : #test }
JollyAssemblerTest >> testCmpWithInto2 [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 4 to: #B;
		cmp: #A with: #B into: #C.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	5 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 4.
	self assert: ((assembly registerNamed: #C) valueIn: memory) equals: FALSE_VALUE
]

{ #category : #test }
JollyAssemblerTest >> testDecrement [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		decrement: #A.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	4 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 4
]

{ #category : #test }
JollyAssemblerTest >> testDecrementInto [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 0 to: #B;
		decrement: #A into: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	6 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 4.
]

{ #category : #test }
JollyAssemblerTest >> testDecrementWordInto [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord1;
		data: #[1 2 3];
		label: #addressForWord2;
		data: #[0 0 0];
		label: #endData;
		decrementWord: #addressForWord1 into: #addressForWord2.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	30 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord1) address accessInteger: memory) equals: 16r010203.
	self assert: ((assembledCode labelNamed: #addressForWord2) address accessInteger: memory) equals: 16r010202.
]

{ #category : #test }
JollyAssemblerTest >> testDecrementWordInto2 [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord1;
		data: #[255 255 255];
		label: #addressForWord2;
		data: #[0 0 0];
		label: #endData;
		decrementWord: #addressForWord1 into: #addressForWord2.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	30 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord1) address accessInteger: memory) equals: 16rFFFFFF.
	self assert: ((assembledCode labelNamed: #addressForWord2) address accessInteger: memory) equals: 16rFFFFFE.
]

{ #category : #test }
JollyAssemblerTest >> testDecrementWordInto3 [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord1;
		data: #[0 0 0];
		label: #addressForWord2;
		data: #[0 0 0];
		label: #endData;
		decrementWord: #addressForWord1 into: #addressForWord2.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	60 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord1) address accessInteger: memory) equals: 16r000000.
	self assert: ((assembledCode labelNamed: #addressForWord2) address accessInteger: memory) equals: 16rFFFFFF.
]

{ #category : #test }
JollyAssemblerTest >> testIncrement [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		increment: #A.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	4 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 6
]

{ #category : #test }
JollyAssemblerTest >> testIncrement2 [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 255 to: #A;
		increment: #A.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	4 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 0
]

{ #category : #test }
JollyAssemblerTest >> testIncrementInto [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 5 to: #A;
		moveCharFrom: 0 to: #B;
		increment: #A into: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	6 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 6.
]

{ #category : #test }
JollyAssemblerTest >> testIncrementInto2 [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 255 to: #A;
		moveCharFrom: 0 to: #B;
		increment: #A into: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	6 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 255.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 0.
]

{ #category : #test }
JollyAssemblerTest >> testIncrementWord [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord;
		data: #[1 2 3];
		label: #endData;
		incrementWord: #addressForWord.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	60 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord) address accessInteger: memory) equals: 16r010204
]

{ #category : #test }
JollyAssemblerTest >> testIncrementWord2 [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord;
		data: #[0 0 0];
		label: #endData;
		incrementWord: #addressForWord.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	30 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord) address accessInteger: memory) equals: 16r000001
]

{ #category : #test }
JollyAssemblerTest >> testIncrementWord3 [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord;
		data: #[255 255 255];
		label: #endData;
		incrementWord: #addressForWord.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	60 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord) address accessInteger: memory) equals: 16r000000
]

{ #category : #test }
JollyAssemblerTest >> testIncrementWord4 [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord;
		data: #[0 255 255];
		label: #endData;
		incrementWord: #addressForWord.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	60 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord) address accessInteger: memory) equals: 16r010000
]

{ #category : #test }
JollyAssemblerTest >> testIncrementWordInto [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord1;
		data: #[1 2 3];
		label: #addressForWord2;
		data: #[0 0 0];
		label: #endData;
		incrementWord: #addressForWord1 into: #addressForWord2.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	30 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord1) address accessInteger: memory) equals: 16r010203.
	self assert: ((assembledCode labelNamed: #addressForWord2) address accessInteger: memory) equals: 16r010204.
]

{ #category : #test }
JollyAssemblerTest >> testIncrementWordInto2 [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #addressForWord1;
		data: #[255 255 255];
		label: #addressForWord2;
		data: #[42 42 42];
		label: #endData;
		incrementWord: #addressForWord1 into: #addressForWord2.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	60 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #addressForWord1) address accessInteger: memory) equals: 16rFFFFFF.
	self assert: ((assembledCode labelNamed: #addressForWord2) address accessInteger: memory) equals: 16r000000.
]

{ #category : #test }
JollyAssemblerTest >> testLookupBankFromFromTo [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 41 to: #A;
		moveCharFrom: 1 to: #B;
		moveCharFrom: 0 to: #C; 
		lookupBank: (assembly reservedMemoryZoneNamed: #ADD_PAGE) address from: #A from: #B to: #C.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	6 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 41.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 1.
	self assert: ((assembly registerNamed: #C) valueIn: memory) equals: 42.
]

{ #category : #test }
JollyAssemblerTest >> testLookupPageFromTo [
	| assembly vm memory |
	assembly := JollyAssembler new.
	
	assembly
		moveCharFrom: 42 to: #A;
		moveCharFrom: 0 to: #B;
		lookupPage: (assembly reservedMemoryZoneNamed: #IDENTITY_PAGE) startAddress from: #A to: #B.
	
	memory := assembly assemble serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	4 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembly registerNamed: #A) valueIn: memory) equals: 42.
	self assert: ((assembly registerNamed: #B) valueIn: memory) equals: 42.
]

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
JollyAssemblerTest >> testMoveWordFromABCTo [
	| assembly vm memory assembledCode |
	assembly := JollyAssembler new.
	
	assembly
		jump: #endData;
		label: #targetForWordMove;
		data: #[0 0 0];
		label: #endData;
		moveCharFrom: 1 to: #A;
		moveCharFrom: 2 to: #B;
		moveCharFrom: 3 to: #C;
		moveWordFrom: #A to: #targetForWordMove.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	7 timesRepeat: [ vm executeInnerLoop ].
	
	self assert: ((assembledCode labelNamed: #targetForWordMove) address access: memory) equals: 1.
	self assert: ((assembledCode labelNamed: #targetForWordMove) address + 1 access: memory) equals: 2.
	self assert: ((assembledCode labelNamed: #targetForWordMove) address + 2 access: memory) equals: 3.
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
