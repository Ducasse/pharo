Class {
	#name : #BaselineOfPharoGT,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharoGT
}

{ #category : #baselines }
BaselineOfPharoGT >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec postLoadDoIt: #'postload:package:'.
				
		spec 
			package: 'OpalCompiler-Tools';
			package: 'GT-Inspector';
			package: 'GT-InspectorExtensions-Core';
			package: 'GT-Playground';
			package: 'GT-Spotter';
			package: 'GT-Spotter-UI';
			package: 'GT-SpotterExtensions-Core';
			package: 'GT-Spotter-Processors';
			package: 'GT-Debugger';
			package: 'GT-BytecodeDebugger';
			package: 'GT-SUnitDebugger';
			package: 'GT-Tests-Debugger';
			package: 'GT-Tests-Inspector';
			package: 'GT-Tests-Playground';
			package: 'GT-Tests-Spotter';
			package: 'GT-Tests-Spotter-Processors';
			package: 'Calypso-SystemPlugins-Spotter'.
			
		spec 
			group: 'Core' with: #('OpalCompiler-Tools' 	'GT-Inspector' 	'GT-InspectorExtensions-Core'
				'GT-Playground'	'GT-Spotter'	'GT-Spotter-UI'	'GT-SpotterExtensions-Core' 'GT-Spotter-Processors'
				'GT-Debugger' 'GT-BytecodeDebugger'	'GT-SUnitDebugger' 'Calypso-SystemPlugins-Spotter');
			group: 'Tests' with: #('GT-Tests-Debugger' 	'GT-Tests-Inspector' 	'GT-Tests-Playground' 
				'GT-Tests-Spotter' 'GT-Tests-Spotter-Processors');
			group: 'default' with: #('Core' 'Tests') ]
]

{ #category : #baselines }
BaselineOfPharoGT >> postload: loader package: packageSpec [
	  
	self class environment at: #GTPlayground ifPresent: [:playground | 
	  Smalltalk tools register: playground as: #workspace.].
	self class environment at: #GTInspector ifPresent: [:inspector | 
	  Smalltalk tools register: inspector as: #inspector.].


]
