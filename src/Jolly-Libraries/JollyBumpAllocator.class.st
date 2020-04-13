Class {
	#name : #JollyBumpAllocator,
	#superclass : #JollyMemoryAllocator,
	#category : #'Jolly-Libraries'
}

{ #category : #generating }
JollyBumpAllocator >> generateFreeOn: assembly [
	"In a bump allocator, free does nothing.
	 Bump allocator create, by essence, memory leak.
	"
	assembly
		label: #free;
		return
]

{ #category : #generating }
JollyBumpAllocator >> generateMallocOn: assembly [
	assembly label: #malloc;
		popFromDataStack: #A;
		pushAddressOfLabelOnDataStack: #heap_pointer;
		fetchDataAtAddressAtDataStackTopInto: #B;
		incrementAddressAtDataStackTop;
		fetchDataAtAddressAtDataStackTopInto: #C;
		incrementAddressAtDataStackTop;
		fetchDataAtAddressAtDataStackTopInto: #D;
		"Drop heap_pointer address from data stack"
		decrement: #SP; decrement: #SP; decrement: #SP;
		"Push heap_pointer value on data stack."
		pushOnDataStack: #B;
		pushOnDataStack: #C;
		pushOnDataStack: #D;
		"Push heap_pointer value on data stack again, this one will be use to update the heap_pointer in memory."
		pushOnDataStack: #B;
		pushOnDataStack: #C;
		pushOnDataStack: #D;
		label: #malloc_loop;
			cmp: #A with: 0;
			jumpIfEqual: #malloc_loop_finished;
			decrementAddressAtDataStackTop;
			jump: #malloc_loop;
			
		label: #malloc_loop_finished;
		"Now, store the new heap_pointer value in memory."
		move: #B to: #A;
		move: #C to: #B;
		move: #D to: #C;
		popFromDataStack: #D;
		atAddressStoreData: #D;
		incrementAddress;
		popFromDataStack: #D;
		atAddressStoreData: #D;
		incrementAddress;
		atAddressStoreData: #D;
		return.
]
