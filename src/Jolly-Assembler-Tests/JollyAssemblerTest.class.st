"
A JollyAssemblerTest is a test class for testing the behavior of JollyAssembler
"
Class {
	#name : #JollyAssemblerTest,
	#superclass : #TestCase,
	#category : #'Jolly-Assembler-Tests'
}

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
	
	self assert: ((assembly registerNamed: #A) address access: memory) equals: 5.
	self assert: ((assembly registerNamed: #B) address access: memory) equals: 6.
]
