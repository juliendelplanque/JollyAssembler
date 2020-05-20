Extension { #name : #BPAddress }

{ #category : #'*Jolly-Assembler' }
BPAddress >> asDirectAccess [
	^ JollyDirectDataAccess address: self
]

{ #category : #'*Jolly-Assembler' }
BPAddress >> asIndirectAccess [
	^ JollyIndirectDataAccess address: self
]
