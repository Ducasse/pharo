"
I check that `FreeTypeNameParser` turns a font's family and style names into a family group name plus slant, weight and stretch values, the way `AbstractFreeTypeFileInfo>>#extractAttributesFromNames` uses it.

## Responsibility:

- Check that slant, weight and stretch words are found in both the family name and the style name, with or without delimiters, and in any letter case.
- Check that the matched words are removed from the family name and that the right `LogicalFont` values are given.
- Check the fallbacks: regular values when nothing matches, and the italic and bold flags when the names say nothing.

## Collaborators: 

- `FreeTypeNameParser`: the object under test, built through `#parseFamily:style:` and `#parseFamily:style:italic:bold:`.
- `LogicalFont`: gives the expected slant, weight and stretch values (`LogicalFont weightBold`, `LogicalFont stretchCondensed`, ...).

## Public API and Key Messages

- `parseFamily:style:` answers a parsed parser for names whose italic and bold flags are false.
- `parseFamily:style:italic:bold:` also sets the two flags, like a font file would.

For example, a semibold italic Source Sans Pro face is parsed as:

```
| parser |
parser := self parseFamily: 'Source Sans Pro' style: 'Semibold Italic'.
parser familyName.            ""'Source Sans Pro'""
parser extractedWeightValue.  ""LogicalFont weightSemiBold""
parser extractedSlantValue.   ""LogicalFont slantItalic""
```

### Implementation Points

The tests do not use any font file or the FreeType library: the parser works on strings only.
"
Class {
	#name : 'FreeTypeNameParserTest',
	#superclass : 'TestCase',
	#category : 'FreeType-Tests-FontManager',
	#package : 'FreeType-Tests',
	#tag : 'FontManager'
}

{ #category : 'helpers' }
FreeTypeNameParserTest >> parseFamily: familyName style: styleName [
	"Answer a parser that has parsed the names of a face whose italic and bold flags are off."

	^ self
		  parseFamily: familyName
		  style: styleName
		  italic: false
		  bold: false
]

{ #category : 'helpers' }
FreeTypeNameParserTest >> parseFamily: familyName style: styleName italic: italicFlag bold: boldFlag [
	"Answer a parser that has parsed the names and flags of a face, as a font file info would give them."

	^ FreeTypeNameParser new
		  familyNameIn: familyName;
		  styleNameIn: styleName;
		  italicFlag: italicFlag;
		  boldFlag: boldFlag;
		  parse;
		  yourself
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testDelimitersAroundWordsAreRemoved [

	| parser |
	parser := self parseFamily: 'Foo_Sans' style: 'Bold, Italic'.
	self assert: parser familyName equals: 'Foo_Sans'.
	self assert: parser extractedWeightValue equals: LogicalFont weightBold.
	self assert: parser extractedSlantValue equals: LogicalFont slantItalic
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testFlagsGiveStyleWhenNamesDoNot [

	| parser |
	parser := self
		          parseFamily: 'Foo'
		          style: ''
		          italic: true
		          bold: true.
	self assert: parser familyName equals: 'Foo'.
	self assert: parser extractedSlant equals: 'Italic'.
	self assert: parser extractedSlantValue equals: LogicalFont slantItalic.
	self assert: parser extractedWeight equals: 'Bold'.
	self assert: parser extractedWeightValue equals: LogicalFont weightBold
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testMatchingIgnoresCase [

	| parser |
	parser := self parseFamily: 'Foo' style: 'EXTRA LIGHT italic'.
	self assert: parser familyName equals: 'Foo'.
	self assert: parser extractedWeight equals: 'EXTRA LIGHT'.
	self assert: parser extractedWeightValue equals: LogicalFont weightExtraLight.
	self assert: parser extractedSlant equals: 'italic'
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testNamesWinOverBoldFlag [

	| parser |
	parser := self
		          parseFamily: 'Foo'
		          style: 'Light'
		          italic: false
		          bold: true.
	self assert: parser extractedWeight equals: 'Light'.
	self assert: parser extractedWeightValue equals: LogicalFont weightLight
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testObliqueIsReportedAsItalic [

	| parser |
	parser := self parseFamily: 'DejaVu Sans' style: 'Oblique'.
	self assert: parser extractedSlant equals: 'Oblique'.
	self assert: parser extractedSlantValue equals: LogicalFont slantItalic
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testRegularStyleKeepsDefaultValues [

	| parser |
	parser := self parseFamily: 'Source Sans Pro' style: 'Regular'.
	self assert: parser familyName equals: 'Source Sans Pro'.
	self assert: parser extractedUpright equals: 'Regular'.
	self assert: parser extractedSlant isNil.
	self assert: parser extractedWeight isNil.
	self assert: parser extractedStretch isNil.
	self assert: parser extractedSlantValue equals: LogicalFont slantRegular.
	self assert: parser extractedWeightValue equals: LogicalFont weightRegular.
	self assert: parser extractedStretchValue equals: LogicalFont stretchRegular
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testStretchInFamilyNameIsRemoved [

	| parser |
	parser := self parseFamily: 'DejaVu Sans Condensed' style: 'Bold'.
	self assert: parser familyName equals: 'DejaVu Sans'.
	self assert: parser extractedStretch equals: 'Condensed'.
	self assert: parser extractedStretchValue equals: LogicalFont stretchCondensed.
	self assert: parser extractedWeightValue equals: LogicalFont weightBold
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testStyleAlreadyInFamilyNameIsNotRepeated [

	| parser |
	parser := self parseFamily: 'Foo-Bold' style: 'Bold'.
	self assert: parser familyName equals: 'Foo'.
	self assert: parser extractedWeight equals: 'Bold'
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testUprightWordOtherThanRegular [

	| parser |
	parser := self parseFamily: 'Arial Narrow' style: 'Book'.
	self assert: parser familyName equals: 'Arial'.
	self assert: parser extractedUpright equals: 'Book'.
	self assert: parser extractedStretchValue equals: LogicalFont stretchNarrow.
	self assert: parser extractedWeightValue equals: LogicalFont weightRegular
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testWeightAndItalicInStyleName [

	| parser |
	parser := self parseFamily: 'Source Sans Pro' style: 'Semibold Italic'.
	self assert: parser familyName equals: 'Source Sans Pro'.
	self assert: parser extractedWeight equals: 'Semibold'.
	self assert: parser extractedWeightValue equals: LogicalFont weightSemiBold.
	self assert: parser extractedSlant equals: 'Italic'.
	self assert: parser extractedSlantValue equals: LogicalFont slantItalic
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testWeightMadeOfTwoWords [

	| parser |
	parser := self parseFamily: 'Source Sans Pro' style: 'Semi Bold'.
	self assert: parser familyName equals: 'Source Sans Pro'.
	self assert: parser extractedWeight equals: 'Semi Bold'.
	self assert: parser extractedWeightValue equals: LogicalFont weightSemiBold
]

{ #category : 'tests' }
FreeTypeNameParserTest >> testWordsWrittenTogetherAreSplit [

	| parser |
	parser := self parseFamily: 'DejaVu Sans' style: 'BoldOblique'.
	self assert: parser familyName equals: 'DejaVu Sans'.
	self assert: parser extractedWeight equals: 'Bold'.
	self assert: parser extractedWeightValue equals: LogicalFont weightBold.
	self assert: parser extractedSlant equals: 'Oblique'
]
