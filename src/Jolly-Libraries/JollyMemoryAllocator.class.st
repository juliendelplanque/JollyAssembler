Class {
	#name : #JollyMemoryAllocator,
	#superclass : #Object,
	#category : #'Jolly-Libraries'
}

{ #category : #generating }
JollyMemoryAllocator class >> generateOn: assembly [
	^ self new
		generateOn: assembly;
		yourself
]

{ #category : #generating }
JollyMemoryAllocator >> generateDataZone: assembly [
	assembly
		jump: #end_of_memory_allocator_data; "In case the lib is included at beginning of assembly."
		label: #heap_pointer;
		data: #[16rFF 16rFF 16rFF]; "Point to the end of memory"
		label: #end_of_memory_allocator_data.
]

{ #category : #generating }
JollyMemoryAllocator >> generateFreeOn: assembly [
	self subclassResponsibility
]

{ #category : #generating }
JollyMemoryAllocator >> generateMallocOn: assembly [
	self subclassResponsibility
]

{ #category : #generating }
JollyMemoryAllocator >> generateOn: assembly [
	self
		generateDataZone: assembly;
		generateMallocOn: assembly;
		generateFreeOn: assembly
]
