"
A JollyEForthAssemblerTest is a test class for testing the behavior of JollyEForthAssembler
"
Class {
	#name : #JollyEForthAssemblerTest,
	#superclass : #TestCase,
	#category : #'Jolly-EForth-Tests'
}

{ #category : #test }
JollyEForthAssemblerTest >> testCodeDefinitionHeaderWithLexiconNameLabel [
	| assembly memory assembledCode |
	assembly := JollyEForthAssembler new.
	
	assembly
		codeDefinitionHeaderWithLexicon: 42 name: 'foo' label: #foo;
		nop;
		codeDefinitionHeaderWithLexicon: 255 name: 'bar' label: #bar;
		nop;
		codeDefinitionHeaderWithLexicon: 21 name: 'foobar' label: #foobar;
		nop.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	self assert: assembly previousWordAddress equals: #foobar.
	"Let's check that the dictionary linked list is built correctly."
	self
		assert: ((assembledCode labelNamed: #foobar) address accessInteger: memory)
		equals: (assembledCode labelNamed: #bar) address memoryAddress.
	self
		assert: ((assembledCode labelNamed: #bar) address accessInteger: memory)
		equals: (assembledCode labelNamed: #foo) address memoryAddress.
	self
		assert: ((assembledCode labelNamed: #foo) address accessInteger: memory)
		equals: 0.
]

{ #category : #test }
JollyEForthAssemblerTest >> testCodeDefinitionHeaderWithLexiconNameLabel2 [
	| assembly memory assembledCode |
	assembly := JollyEForthAssembler new.
	
	assembly
		codeDefinitionHeaderWithLexicon: 42 name: 'foo' label: #foo;
		nop.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	self assert: assembly previousWordAddress equals: #foo.
	self
		assert: ((assembledCode labelNamed: #foo) address accessInteger: memory)
		equals: 0.
	self
		assert: ((assembledCode labelNamed: #foo) address + 3 access: memory)
		equals: 42.
	self
		assert: ((assembledCode labelNamed: #foo) address + 4 access: memory)
		equals: 3.
	self
		assert: ((assembledCode labelNamed: #foo) address + 5 access: memory)
		equals: $f asciiValue.
	self
		assert: ((assembledCode labelNamed: #foo) address + 6 access: memory)
		equals: $o asciiValue.
	self
		assert: ((assembledCode labelNamed: #foo) address + 7 access: memory)
		equals: $o asciiValue.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDeallocateDataStack [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		deallocateDataStack.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineBranch [

	self flag: #toImplement.
	self assert: false
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineCFetch [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineCFetch;
		
		label: #_start;
		jump: #'cFetchWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	16r424242 asBPAddress
		store: 42 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 42
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineCStore [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineCStore;
		
		label: #_start;
		jump: #'cStoreWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 and 42 are on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK) + 3
		storeInteger: 16r424242 in: memory.
		
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 42 in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
		
	self
		assert: (16r424242 asBPAddress access: memory)
		equals: 42
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineCStore2 [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineCStore;
		
		label: #_start;
		jump: #'cStoreWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 and 42 are on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK) + 3
		storeInteger: 16r424242 in: memory.
		
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16rFFFF2A in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
		
	self
		assert: (16r424242 asBPAddress access: memory)
		equals: 42
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineConditionalBranch [

	self flag: #toImplement.
	self assert: false
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineCopyTopOfReturnStackToDataStack [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineCopyTopOfReturnStackToDataStack;
		
		label: #_start;
		jump: #'copyTopOfReturnStackToDataStack-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #RP)
		storeInteger: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3
		in: memory.
	
	(assembly addressOfMemoryZone: #RETURN_STACK) - 3
		storeInteger: 16r424242 in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 16r424242.
		
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #RETURN_STACK) - 3 accessInteger: memory)
		equals: 16r424242.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineDoList [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineDoList;
		jump: #doLIST.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	(assembly addressOfMemoryZone: #IP)
		storeAddress: 16r424242 asBPAddress in: memory.
		
	(assembly addressOfMemoryZone: #WP)
		storeAddress: 16r524242 asBPAddress in: memory.
		
	16r524245 asBPAddress
		storeAddress: 16r534242 asBPAddress in: memory.
	
	16r534242 asBPAddress
		storeAddress: 16r544242 asBPAddress in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: 16r534242 orExecutedInstructionsCountReach: 2000.
	
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #RETURN_STACK) - 3 accessInteger: memory)
		equals: 16r424242.
		
	self
		assert: ((assembly addressOfMemoryZone: #WP) accessInteger: memory)
		equals: 16r534242.
	
	self
		assert: ((assembly addressOfMemoryZone: #IP) accessInteger: memory)
		equals: 16r524248.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineDoLit [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineDoLit;
		label: #_start;
		jump: #'doLitWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	(assembly addressOfMemoryZone: #IP)
		storeAddress: 16r424242 asBPAddress in: memory.
		
	16r424242 asBPAddress
		storeAddress: 42 asBPAddress in: memory.
		
	16r424245 asBPAddress
		storeAddress: 16r524245 asBPAddress in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: 16r524245 orExecutedInstructionsCountReach: 2000.
	
	self
		assert: ((assembly addressOfMemoryZone: #IP) accessInteger: memory)
		equals: 16r424248.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 42.
		
	self
		assert: vm programCounter equals: 16r524245
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineDrop [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineDrop;
		
		label: #_start;
		jump: #'dropWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
	
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	vm
		executeInnerLoopUntilReachAddress: (assembledCode labelNamed: #'dropWord-next') address memoryAddress 
		orExecutedInstructionsCountReach: 1000.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineDup [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineDup;
		
		label: #_start;
		jump: #'dupWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 16r424242.
	
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) + 3 accessInteger: memory)
		equals: 16r424242
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineExecute [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineExecute;
		label: #_start;
		jump: #'executeWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK) + 3
		storeInteger: 16r424242 in: memory.
	
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: 16r424242 orExecutedInstructionsCountReach: 2000.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
		
	self
		assert: vm programCounter
		equals: 16r424242
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineExit [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineExit;
		
		label: #_start;
		jump: #'exitWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
	
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress.
	
	"Simulate that the address 16r424242 is on the return stack."
	(assembly addressOfMemoryZone: #RP)
		storeInteger: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3
		in: memory.
	
	(assembly addressOfMemoryZone: #RETURN_STACK) - 3
		storeInteger: 16r424242 in: memory.
		
	16r424242 asBPAddress
		storeInteger: 16r524242 in: memory.
	
	self
		assert: (((assembly addressOfMemoryZone: #RP) accessInteger: memory) asBPAddress accessInteger: memory)
		equals: 16r424242.
	
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: 16r524242 orExecutedInstructionsCountReach: 500.
	
	self
		assert: ((assembly addressOfMemoryZone: #IP) accessInteger: memory)
		equals: 16r424245.
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress.
	self
		assert: ((assembly addressOfMemoryZone: #WP) accessInteger: memory)
		equals: 16r524242
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineFetch [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineFetch;
		
		label: #_start;
		jump: #'fetchWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	16r424242 asBPAddress
		storeInteger: 42 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 42
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineNext [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineNext;
		label: #_start;
		jump: #'nextWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r000001 is on the data stack."
	(assembly addressOfMemoryZone: #RP)
		storeInteger: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3
		in: memory.
	
	(assembly addressOfMemoryZone: #RETURN_STACK) - 3
		storeInteger: 16r000001 in: memory.
	
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
				
	self fail: 'Need to see how to test that.'
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineOver [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineOver;
		
		label: #_start;
		jump: #'overWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242, 16r424243 are on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424243 in: memory.
		
	(assembly addressOfMemoryZone: #DATA_STACK) + 3
		storeInteger: 16r424242 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: (assembledCode labelNamed: #'overWord-next') address memoryAddress orExecutedInstructionsCountReach: 2000.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 9.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 16r424243.
	
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) + 3 accessInteger: memory)
		equals: 16r424242.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) + 6 accessInteger: memory)
		equals: 16r424243.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefinePopDataStackToReturnStack [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		definePopDataStackToReturnStack;
		
		label: #_start;
		jump: #'popDataStackToReturnStack-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
		
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #RETURN_STACK) - 3 accessInteger: memory)
		equals: 16r424242.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefinePopReturnStackToDataStack [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		definePopReturnStackToDataStack;
		
		label: #_start;
		jump: #'popReturnStackToDataStack-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #RP)
		storeInteger: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress - 3
		in: memory.
	
	(assembly addressOfMemoryZone: #RETURN_STACK) - 3
		storeInteger: 16r424242 in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 16r424242.
		
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #RETURN_STACK) memoryAddress
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineRPFetch [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineRPFetch;
		
		label: #_start;
		jump: #'rpFetchWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	vm
		executeInnerLoopUntilReachAddress: (assembledCode labelNamed: #'rpFetchWord-next') address memoryAddress 
		orExecutedInstructionsCountReach: 1000.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineRPStore [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineRPStore;
		
		label: #_start;
		jump: #'rpStoreWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 is on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 3.
	
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	vm
		executeInnerLoopUntilReachAddress: (assembledCode labelNamed: #'rpStoreWord-next') address memoryAddress 
		orExecutedInstructionsCountReach: 1000.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
		
	self
		assert: ((assembly addressOfMemoryZone: #RP) accessInteger: memory)
		equals: 16r424242.
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineSPFetch [

	self flag: #toImplement.
	self assert: false
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineSPStore [

	self flag: #toImplement.
	self assert: false
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineStore [
	| assembly memory assembledCode vm |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineStore;
		
		label: #_start;
		jump: #'storeWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242 and 42 are on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK) + 3
		storeInteger: 16r424242 in: memory.
		
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 42 in: memory.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	500 timesRepeat: [ vm executeInnerLoop ].
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress.
		
	self
		assert: (16r424242 asBPAddress accessInteger: memory)
		equals: 42
]

{ #category : #test }
JollyEForthAssemblerTest >> testDefineSwap [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		defineSwap;
		
		label: #_start;
		jump: #'swapWord-xt'.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	"Simulate that the address 16r424242, 16r424243 are on the data stack."
	(assembly addressOfMemoryZone: #SP)
		storeInteger: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6
		in: memory.
	
	(assembly addressOfMemoryZone: #DATA_STACK)
		storeInteger: 16r424242 in: memory.
		
	(assembly addressOfMemoryZone: #DATA_STACK) + 3
		storeInteger: 16r424243 in: memory.
		
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6.
		
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: (assembledCode labelNamed: #'swapWord-next') address memoryAddress orExecutedInstructionsCountReach: 3000.
	
	self
		assert: ((assembly addressOfMemoryZone: #SP) accessInteger: memory)
		equals: (assembly addressOfMemoryZone: #DATA_STACK) memoryAddress + 6.
		
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) accessInteger: memory)
		equals: 16r424243.
	
	self
		assert: ((assembly addressOfMemoryZone: #DATA_STACK) + 3 accessInteger: memory)
		equals: 16r424242
]

{ #category : #test }
JollyEForthAssemblerTest >> testNext [
	| assembly memory assembledCode vm count |
	assembly := JollyEForthAssembler new.
	
	assembly
		next.
	
	assembledCode := assembly assemble.
	memory := assembledCode serialize.
	
	(assembly addressOfMemoryZone: #IP)
		storeAddress: 16r424242 asBPAddress in: memory.
	16r424242 asBPAddress
		storeAddress: 16r524242 asBPAddress in: memory.
	
	self assert: ((assembly addressOfMemoryZone: #IP) accessInteger: memory) equals: 16r424242.
	self assert: (16r424242 asBPAddress accessInteger: memory) equals: 16r524242.
	self assert: ((assembly addressOfMemoryZone: #WP) accessInteger: memory) equals: 0.
	
	vm := JollyVirtualMachine new
				memory: memory;
				loadProgramCounter;
				yourself.
	
	count := vm executeInnerLoopUntilReachAddress: 16r524242 orExecutedInstructionsCountReach: 1e6.
	
	self assert: ((assembly addressOfMemoryZone: #IP) accessInteger: memory) equals: 16r424245.
	self assert: ((assembly addressOfMemoryZone: #WP) accessInteger: memory) equals: 16r524242.
	self assert: vm programCounter equals: 16r524242
]
