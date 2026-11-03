"
I check how a `FreeTypeFontFamily` collects its members, adds simulated styles for the ones its font files lack, and picks the member closest to a requested stretch, weight and slant.

## Responsibility:

- Check that members are added from font file infos, without duplicate style names, and know their family.
- Check that simulated bold and oblique members are added only when the family has no real face for that style.
- Check that `closestMemberWithStretchValue:weightValue:slantValue:` answers the best matching member.

## Collaborators: 

- `FreeTypeFontFamily`: the object under test.
- `FreeTypeFileInfo`: built in memory from a family and style name (no font file is read); `extractAttributesFromNames` derives its weight, slant and stretch with `FreeTypeNameParser`.
- `FreeTypeFontFamilyMember`: the members whose `styleName`, `weightValue`, `slantValue` and `isSimulatedStyle` are checked.
- `LogicalFont`: gives the weight, slant and stretch values.

## Public API and Key Messages

- `familyWithStyles:` answers a family whose members come from the given style names.
- `styleNamesOf:` and `simulatedStyleNamesOf:` answer the style names of a family's members as sets, since member order is not part of the behaviour.

For example, a family with only a regular face gets three simulated styles:

```
| family |
family := self familyWithStyles: #('Regular').
family addSimulatedMembers.
self simulatedStyleNamesOf: family.   ""a Set('Bold' 'Oblique' 'Bold Oblique')""
```

### Implementation Points

Nothing here needs the FreeType library or a font file, so the tests are fast and do not touch the global font provider.
The italic versus oblique bug in `AbstractFontFamilyMember>>#closenessVectorForStretch:slant:weight:` is recorded in the backlog and has no test here yet.
"
Class {
	#name : 'FreeTypeFontFamilyTest',
	#superclass : 'TestCase',
	#category : 'FreeType-Tests-FontManager',
	#package : 'FreeType-Tests',
	#tag : 'FontManager'
}

{ #category : 'helpers' }
FreeTypeFontFamilyTest >> closestStyleIn: aFamily weight: weightValue slant: slantValue [
	"Answer the style name of the member of aFamily that best matches a regular-width face of the given weight and slant."

	^ (aFamily closestMemberWithStretchValue: LogicalFont stretchRegular weightValue: weightValue slantValue: slantValue) styleName
]

{ #category : 'helpers' }
FreeTypeFontFamilyTest >> familyWithStyles: styleNames [
	"Answer a family whose members are built from one file info per style name."

	^ (FreeTypeFontFamily new
		   familyName: 'Test Sans';
		   yourself)
		  addMembersFromFileInfos: (styleNames collect: [ :each | self fileInfoWithStyle: each ]);
		  yourself
]

{ #category : 'helpers' }
FreeTypeFontFamilyTest >> fileInfoWithStyle: styleName [
	"Answer an in-memory file info for a face of the test family, with attributes derived from its names."

	^ FreeTypeFileInfo new
		  familyName: 'Test Sans';
		  styleName: styleName;
		  italic: false;
		  bold: false;
		  index: 0;
		  extractAttributesFromNames;
		  yourself
]

{ #category : 'helpers' }
FreeTypeFontFamilyTest >> simulatedStyleNamesOf: aFamily [

	^ (aFamily members select: [ :each | each isSimulatedStyle ] thenCollect: [ :each | each styleName ]) asSet
]

{ #category : 'helpers' }
FreeTypeFontFamilyTest >> styleNamesOf: aFamily [

	^ aFamily members collect: [ :each | each styleName ] as: Set
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testAddMembersFromFileInfos [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Bold Italic' ).
	self assert: (self styleNamesOf: family) equals: #( 'Regular' 'Bold Italic' ) asSet.
	self assert: (family members allSatisfy: [ :each | each family == family ]).
	self deny: (family members anySatisfy: [ :each | each isSimulatedStyle ])
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testAddMembersFromFileInfosSkipsDuplicateStyles [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Bold' 'Bold' ).
	self assert: family members size equals: 2
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testClosestMemberExactMatch [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Bold' 'Italic' 'Bold Italic' ).
	self assert: (self closestStyleIn: family weight: LogicalFont weightRegular slant: LogicalFont slantRegular) equals: 'Regular'.
	self assert: (self closestStyleIn: family weight: LogicalFont weightBold slant: LogicalFont slantRegular) equals: 'Bold'.
	self assert: (self closestStyleIn: family weight: LogicalFont weightRegular slant: LogicalFont slantItalic) equals: 'Italic'.
	self assert: (self closestStyleIn: family weight: LogicalFont weightBold slant: LogicalFont slantItalic) equals: 'Bold Italic'
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testClosestMemberNearestWeight [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Bold' ).
	self assert: (self closestStyleIn: family weight: LogicalFont weightSemiBold slant: LogicalFont slantRegular) equals: 'Bold'.
	self assert: (self closestStyleIn: family weight: LogicalFont weightLight slant: LogicalFont slantRegular) equals: 'Regular'.
	self assert: (self closestStyleIn: family weight: LogicalFont weightBlack slant: LogicalFont slantRegular) equals: 'Bold'
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testMediumCountsAsRegularWhenSimulatingOblique [
	"A Medium face with a real Oblique face (like FreeSans) must not get a second, simulated oblique."

	| family |
	family := self familyWithStyles: #( 'Medium' 'Oblique' ).
	family addSimulatedMembers.
	self assert: (self simulatedStyleNamesOf: family) equals: #( 'Bold' 'Bold Oblique' ) asSet
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testMemberWithStyleName [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Bold' ).
	self assert: (family memberWithStyleName: 'Bold') weightValue equals: LogicalFont weightBold.
	self assert: (family memberWithStyleName: 'Italic') isNil
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testMembersGetValuesFromTheirStyleName [

	| member |
	member := (self familyWithStyles: #( 'Semibold Italic' )) memberWithStyleName: 'Semibold Italic'.
	self assert: member weightValue equals: LogicalFont weightSemiBold.
	self assert: member slantValue equals: LogicalFont slantItalic.
	self assert: member stretchValue equals: LogicalFont stretchRegular
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testNoSimulatedBoldForLightOnlyFamily [
	"Only regular to medium faces are made bold: emboldening a light face would not look bold."

	| family |
	family := self familyWithStyles: #( 'Light' ).
	family addSimulatedMembers.
	self assert: (self simulatedStyleNamesOf: family) equals: #( 'Light Oblique' ) asSet
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testNoSimulatedBoldWhenRealBoldExists [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Bold' ).
	family addSimulatedMembers.
	self assert: (self simulatedStyleNamesOf: family) equals: #( 'Oblique' 'Bold Oblique' ) asSet.
	self deny: (family memberWithStyleName: 'Bold') isSimulatedStyle
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testNoSimulatedObliqueWhenRealItalicExists [

	| family |
	family := self familyWithStyles: #( 'Regular' 'Italic' ).
	family addSimulatedMembers.
	self assert: (self simulatedStyleNamesOf: family) equals: #( 'Bold' 'Bold Italic' ) asSet
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testRebuildSimulatedMembersReplacesOldOnes [
	"Once a real Black face joins, the regular face is no longer the heaviest, so the simulated Bold must go."

	| family |
	family := self familyWithStyles: #( 'Regular' ).
	family addSimulatedMembers.
	family addMember: (FreeTypeFontFamilyMember fromFileInfo: (self fileInfoWithStyle: 'Black')).
	family rebuildSimulatedMembers.
	self assert: (self styleNamesOf: family) equals: #( 'Regular' 'Black' 'Oblique' 'Black Oblique' ) asSet.
	self assert: family members size equals: 4
]

{ #category : 'tests' }
FreeTypeFontFamilyTest >> testSimulatedStylesForRegularOnlyFamily [

	| family bold boldOblique oblique |
	family := self familyWithStyles: #( 'Regular' ).
	family addSimulatedMembers.
	self assert: (self simulatedStyleNamesOf: family) equals: #( 'Bold' 'Oblique' 'Bold Oblique' ) asSet.
	bold := family memberWithStyleName: 'Bold'.
	self assert: bold weightValue equals: LogicalFont weightBold.
	self assert: bold slantValue equals: LogicalFont slantRegular.
	oblique := family memberWithStyleName: 'Oblique'.
	self assert: oblique weightValue equals: LogicalFont weightRegular.
	self assert: oblique slantValue equals: LogicalFont slantItalic.
	boldOblique := family memberWithStyleName: 'Bold Oblique'.
	self assert: boldOblique weightValue equals: LogicalFont weightBold.
	self assert: boldOblique slantValue equals: LogicalFont slantItalic
]
