Extension { #name : #BPLabelReference }

{ #category : #'*Jolly-Assembler' }
BPLabelReference >> asDirectAccess [
	^ JollyDirectDataAccess address: self
]

{ #category : #'*Jolly-Assembler' }
BPLabelReference >> asIndirectAccess [
	^ JollyIndirectDataAccess address: self
]
