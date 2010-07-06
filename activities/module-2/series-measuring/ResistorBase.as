﻿﻿﻿package {

	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import Globe;
	
	// Resistor 4 band
	public class ResistorBase extends DragItShift
	{
	    public static const LEFT:Number = 0;
	    public static const RIGHT:Number = 1;
	    
	    private var leftEnd:ResistorLead = null;
	    private var rightEnd:ResistorLead = null;
	    
		private var m_bandCount:int;
		private var m_resistanceValue:Number = NaN;
		private var m_pngBandSuffix:String;
		
		private var bandOneColor:String = "blue";
		private var bandTwoColor:String = "blue";
		private var bandThreeColor:String = "blue";
		private var bandFourColor:String = "blue";
		private var bandToleranceColor:String = "blue";
		
		private var componentName:String;
		
		private var probeOnLeft:Boolean = false;
		private var probeOnRight:Boolean = false;
		
		//////////public variables for breadboard probeQuery_handler
		public var blackProbeOnRight:Boolean = false;
		public var redProbeOnRight:Boolean = false;
		public var blackProbeOnLeft:Boolean = false;
		public var redProbeOnLeft:Boolean = false;
		
		private var sndClickIt:clickit3;
		private var sndClickItChannel:SoundChannel;
		private var transform1:SoundTransform=new SoundTransform();
		
		private var resistorTipLeftX:Number;
		private var resistorTipLeftY:Number;
		private var resistorTipRightX:Number;
		private var resistorTipRightY:Number;
		
		private var currentHoleOne:MovieClip = null;
		private var currentHoleTwo:MovieClip = null;
		
		private var resistorLeftLocation:String;
		private var resistorRightLocation:String;
		
		//variables to hold value of resistorLeft and RightLocations for probe functions
		private var resistorLeftCoordinates:String;
		private var resistorRightCoordinates:String;
		
		private var localProbeBlackLeftLocation:String = null;
		private var localProbeBlackRightLocation:String = null;
		private var localProbeRedLeftLocation:String = null;
		private var localProbeRedRightLocation:String = null;
		
		public function ResistorBase(bandCount:int, pngBandSuffix:String)
		{
		    leftEnd = new ResistorLeftLead(this.name + '_lead1',
		        this.getChildByName('resistorEndLeft'),
		        this.getChildByName('resistor_rollover_left'),
		        this.getChildByName('probe_engaged_left'),
		        this.getChildByName('resistorEndLeftBroken'));
		    rightEnd = new ResistorRightLead(this.name + '_lead2',
		        this.getChildByName('resistorEndRight'),
		        this.getChildByName('resistor_rollover_right'),
		        this.getChildByName('probe_engaged_right'),
		        this.getChildByName('resistorEndRightBroken'));

			m_bandCount = bandCount;
			m_pngBandSuffix = pngBandSuffix;
			
			//resistor tip variables relative to resistor x value
			//NEW resistor tip values
//			resistorTipLeftX = this.x + (getChildByName("resistorEndLeft").x - getChildByName("resistorEndLeft").width);
//			resistorTipLeftY = this.y + getChildByName("resistorEndLeft").y;
//			resistorTipRightX = this.x + (getChildByName("resistorEndRight").x + getChildByName("resistorEndRight").width);
//			resistorTipRightY = this.y + getChildByName("resistorEndRight").y;

			this.getChildByName("leftRestore").alpha = 0;
			this.getChildByName("rightRestore").alpha = 0;

			//testResistorTips();
			
			this.addEventListener(Event.ADDED_TO_STAGE, added_to_stage_handler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage_handler);
			this.getChildByName("leftBreak").addEventListener(MouseEvent.MOUSE_UP, breakLeftResistor);
			this.getChildByName("rightBreak").addEventListener(MouseEvent.MOUSE_UP, breakRightResistor);
			this.getChildByName("leftRestore").addEventListener(MouseEvent.MOUSE_UP, restoreLeftResistor);
			this.getChildByName("rightRestore").addEventListener(MouseEvent.MOUSE_UP, restoreRightResistor);
			this.addEventListener(Event.ENTER_FRAME, resistorLocationInitialValues)
		
			if (stage != null)
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			
		}
		
		public function getLeftEnd() {
		    return leftEnd;
		}
		
		public function getRightEnd() {
		    return rightEnd;
		}
		
		private function mouseUpHandler(mevt:MouseEvent):void
		{
			onResistorMove_handler(mevt);
			//probeLeft_handler(mevt);
			//probeRight_handler(mevt);
			probeLocationAssignment_handler(mevt);
			//probeQuery_handler(mevt);
		}
		private function mouseMoveHandler(mevt:MouseEvent):void
		{
			resistor_rollovers_right_handler(mevt);
			resistor_rollovers_left_handler(mevt);
		}
		private function breakLeftResistor(event:MouseEvent):void 
		{
			this.getChildByName("leftBreak").alpha=0;
			this.getChildByName("leftRestore").alpha=1;
			this.getChildByName("leftRestore").addEventListener(MouseEvent.MOUSE_UP, restoreLeftResistor);
			this.getChildByName("resistorEndLeft").alpha=0;
			this.getChildByName("resistorEndLeft").x += 1000;
			this.getChildByName("resistorEndLeftBroken").alpha=1;
			this.resistorTipLeftX -= 45  ;
			//this.resistorOnBoard();  This line of code is duplicated in the move resistor function 
	  	 } 
		 
		private function breakRightResistor(event:MouseEvent):void 
		{
			this.getChildByName("rightBreak").alpha=0;
			this.getChildByName("rightRestore").alpha=1;
			this.getChildByName("rightRestore").addEventListener(MouseEvent.MOUSE_UP, restoreRightResistor);
			this.getChildByName("resistorEndRight").alpha=0;
			this.getChildByName("resistorEndRight").x += 1000;
			this.getChildByName("resistorEndRightBroken").alpha=1;
			this.resistorTipRightX += 45  ;
			//this.resistorOnBoard();  This line of code is exectued on resistor_move function
	  	 } 
		
		private function restoreLeftResistor(event:MouseEvent):void 
		{

			this.getChildByName("leftBreak").alpha=1;
			this.getChildByName("leftRestore").alpha=0;
			this.getChildByName("leftRestore").removeEventListener(MouseEvent.MOUSE_UP, restoreLeftResistor);
			this.getChildByName("resistorEndLeft").alpha=1;
			this.getChildByName("resistorEndLeft").x = 44.45;
			this.getChildByName("resistorEndLeftBroken").alpha=0;
			this.resistorTipLeftX += 45  ;
			//this.resistorOnBoard();  This line of code is exectued on resistor_move function
	  	 } 
		 
		private function restoreRightResistor(event:MouseEvent):void 
		{
		
			this.getChildByName("rightBreak").alpha=1;
			this.getChildByName("rightRestore").alpha=0;
			this.getChildByName("rightRestore").removeEventListener(MouseEvent.MOUSE_UP, restoreRightResistor);
			this.getChildByName("resistorEndRight").alpha=1;
			this.getChildByName("resistorEndRight").x = 130.45;
			this.getChildByName("resistorEndRightBroken").alpha=0;
			this.resistorTipRightX -= 45  ;
			//this.resistorOnBoard();  This line of code is exectued on resistor_move function
	  	 } 
		
		private function added_to_stage_handler(evt:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		private function removed_from_stage_handler(evt:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		private function resistorLocationInitialValues(event:Event):void
		{
			resistorTipLeftX = this.x + (getChildByName("resistorEndLeft").x - getChildByName("resistorEndLeft").width);
			resistorTipLeftY = this.y + getChildByName("resistorEndLeft").y;
			resistorTipRightX = this.x + (getChildByName("resistorEndRight").x + getChildByName("resistorEndRight").width);
			resistorTipRightY = this.y + getChildByName("resistorEndRight").y;
			resistorOnBoard();
			//  replace 'color string' with the actual values of the resistors in ohms.
			//componentName = ExternalInterface.call('breadModel', 'insert', 'resistor', resistorLeftLocation + ',' + resistorRightLocation, bandOneColor + ',' + bandTwoColor + ',' + bandThreeColor + ',' + bandFourColor);
			removeEventListener(Event.ENTER_FRAME, resistorLocationInitialValues);
		}
		
		public function resistorOnBoard():void
		{
		    trace('ENTER ResistorBase#resistorOnBoard');
			
			if (currentHoleOne != null )
			{
				currentHoleOne.gotoAndStop(1);
				currentHoleOne = null;
			}
			
			if (currentHoleTwo != null )
			{
				currentHoleTwo.gotoAndStop(1);
				currentHoleTwo = null;
			}
			
			//for every row ...
			if (parent != null && MovieClip(parent).rows != null)
			{
				for(var rowNum:int = 1; rowNum<=10; rowNum++)
				{
					//start at left of grid
					//accessin the list of row by index
					var row:Array = MovieClip(parent).rows[rowNum]; 
					
					//for every hole in the row...
					for (var holeNum:int = 1; holeNum <=30; holeNum++)
					{
						var h:MovieClip = row[holeNum];
						//trace("h.x = " + h.x + " " + "h.y = " + h.y);
						var boardRow:String;
						
						switch(rowNum)
						{
							case 1:
								boardRow="a";
								break;
							case 2:
								boardRow="b";
								break;
							case 3:
								boardRow="c";
								break;
							case 4:
								boardRow="d";
								break;
							case 5:
								boardRow="e";
								break;
							case 6:
								boardRow="f";
								break;
							case 7:
								boardRow="g";
								break;
							case 8:
								boardRow="h";
								break;
							case 9:
								boardRow="i";
								break;
							case 10:
								boardRow="j";
								break;
						}
						
						
						if (  (resistorTipLeftX > h.x) &&  (resistorTipLeftX < h.x + 12)  &&  (resistorTipLeftY > h.y) &&  (resistorTipLeftY < h.y + 12) )
						{
							currentHoleOne = h;
							h.gotoAndStop(2);
							resistorLeftLocation = boardRow+holeNum;
							trace (this.name + " " + resistorLeftLocation + " Left On" );
							//trace("resistorTipLeftY = " + resistorTipLeftY + " h.y = " + h.y);
							//trace(this.name + " Row = " + boardRow + " Column = " + holeNum + " Left Side On");
						}
							
						else if (  (resistorTipRightX > h.x) &&  (resistorTipRightX < h.x + 12)  &&  (resistorTipRightY > h.y) &&  (resistorTipRightY < h.y + 12) )
						{
							currentHoleTwo = h;
							h.gotoAndStop(2);
							resistorRightLocation = boardRow+holeNum;
							trace (this.name + " " + resistorRightLocation + " Right On" );
							//trace(this.name + " Row = " + boardRow + " Column = " + holeNum + " Left Side On");
						}
						else
						{
							resistorLeftLocation = "empty";
							resistorRightLocation = "empty";
						}
					
						if (resistorLeftLocation != "empty")
						{
							resistorLeftCoordinates = resistorLeftLocation;
						}
						
						if (resistorRightLocation != "empty")
						{
							resistorRightCoordinates = resistorRightLocation;
						}
					}
				}
			}
			//trace(this.name  +  " " + "resistorLeftCoordinates" +  " " + resistorLeftCoordinates);
//			trace(this.name  +  " " + "resistorRightCoordinates" + " " + resistorRightCoordinates);
			//Globe.resistance = ExternalInterface.call('breadModel', 'query', 'voltage', resistorLeftLocation + "," + resistorRightLocation, '200k');
			
			leftEnd.setLocation(resistorLeftCoordinates);
			rightEnd.setLocation(resistorRightCoordinates);
		}
		
		
		
private function onResistorMove_handler(event:MouseEvent):void
		{
			var newResistorTipLeftX:Number = this.x + (getChildByName("resistorEndLeft").x - (getChildByName("resistorEndLeft").width) );
			var newResistorTipLeftY:Number = this.y + getChildByName("resistorEndLeft").y;
			var newResistorTipRightX:Number = this.x + (getChildByName("resistorEndRight").x + (getChildByName("resistorEndRight").width) );
			var newResistorTipRightY:Number = this.y + getChildByName("resistorEndRight").y;
			
		//	trace( this.name + " x= " + this.x);	
		//	trace( this.name + " y= " + this.y);	
			
			if ((newResistorTipLeftX != resistorTipLeftX) || (newResistorTipLeftY != resistorTipLeftY) )
			{
				resistorTipLeftX = newResistorTipLeftX;
				resistorTipLeftY = newResistorTipLeftY;
				resistorTipRightX = newResistorTipRightX;
				resistorTipRightY = newResistorTipRightY;
				this.resistorOnBoard();
				//ExternalInterface.call('breadModel', 'move', componentName, resistorLeftLocation + ',' + resistorRightLocation);
				
				//trace( this.name + " x= " + resistorTipLeftX + " y= " + resistorTipLeftY);
			}
			
			else if ((newResistorTipRightX != resistorTipRightX) || (newResistorTipRightY != resistorTipRightY) )
			{
				resistorTipLeftX = newResistorTipLeftX;
				resistorTipLeftY = newResistorTipLeftY;
				resistorTipRightX = newResistorTipRightX;
				resistorTipRightY = newResistorTipRightY;
				this.resistorOnBoard();
				//ExternalInterface.call('breadModel', 'move', componentName, resistorLeftLocation + ',' + resistorRightLocation);
					
				//trace( this.name + " x= " + resistorTipLeftX + " y= " + resistorTipLeftY);
			}
		}

		
		private const bandColorMap:Array = [
			"black",					// 0
			"brown", "red", "orange", "yellow", "green",	// 1-5
			"blue", "violet", "grey", "white",		// 6-9
			"silver", "gold"				// Tolerance 5%, 10%
		];
		
		private function randomizeResistance():void
		{
			var randnumValue:Vector.<int> = new Vector.<int>();
			
			//band 1 has 9 colors; sets a random number between 1 and 9//
			randnumValue.push(int(Math.floor(Math.random() * 8 + 1)));
			//trace(randnum_b1);
			
			//band 2 has 10 colors; sets a random number between 0 and 9//
			randnumValue.push(int(Math.floor(Math.random() * 9)));
			//trace(randnum_b2);
						
			//band 3 has 10 colors; sets a random number between 0 and 9//
			randnumValue.push(int(Math.floor(Math.random() * 9)));
			//trace(randnum_b3);
						
			//band 4 has 9 colors; sets a random number between 0 and 8//
			randnumValue.push(int(Math.floor(Math.random() * 8)));
			//trace(randnum_b3);
			
			//band 5 has 4 colors; sets a random number between 1 and 4//
			const tolerances:Array = [
				0.01, 0.1, 0.25, 0.5, 1, 2, 5, 10
			];
			
			const toleranceValue:Number = tolerances[Math.floor(Math.random() * 8)];
			
			//setColorBands(randnumValue, toleranceValue);
		}
		
		private var m_bandOneLoader:Loader = null;
		private var m_bandTwoLoader:Loader = null;
		private var m_bandThreeLoader:Loader = null;
		private var m_bandFourLoader:Loader = null;
		private var m_bandToleranceLoader:Loader = null;
			
        public function setColorBands(colors:Array) {

            const toleranceBandName:String = (m_bandCount > 4) ? "band5" : "band4";
            
            if (m_bandOneLoader != null)
                Sprite(this.getChildByName("band1")).removeChild(m_bandOneLoader);
            if (m_bandTwoLoader != null)
                Sprite(this.getChildByName("band2")).removeChild(m_bandOneLoader);
            if (m_bandThreeLoader != null)
                Sprite(this.getChildByName("band3")).removeChild(m_bandOneLoader);
            if (m_bandFourLoader != null)
                Sprite(this.getChildByName("band4")).removeChild(m_bandOneLoader);
            if (m_bandToleranceLoader != null)
                Sprite(this.getChildByName(toleranceBandName)).removeChild(m_bandToleranceLoader);
        
            //load image into Band1
            m_bandOneLoader = new Loader(); 
            Sprite(this.getChildByName("band1")).addChild(m_bandOneLoader); 
            var bandOneBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/t_" + colors[0] + ".png"); 
            m_bandOneLoader.load(bandOneBitmap); 
            
            //load image into Band2
            m_bandTwoLoader = new Loader(); 
            Sprite(this.getChildByName("band2")).addChild(m_bandTwoLoader); 
            var bandTwoBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + colors[1] + ".png"); 
            m_bandTwoLoader.load(bandTwoBitmap); 
            
            //load image into Band3
            m_bandThreeLoader = new Loader(); 
            Sprite(this.getChildByName("band3")).addChild(m_bandThreeLoader); 
            var bandThreeBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + colors[2] + ".png"); 
            m_bandThreeLoader.load(bandThreeBitmap);
            
            //load image into Band4
            m_bandFourLoader = new Loader(); 
            Sprite(this.getChildByName("band4")).addChild(m_bandFourLoader); 
            var bandFourBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + colors[3] + ".png"); 
            m_bandFourLoader.load(bandFourBitmap); 

            //load image into Band5
            if (colors.length > 4) {
              m_bandToleranceLoader = new Loader();
              Sprite(this.getChildByName(toleranceBandName)).addChild(m_bandToleranceLoader);
              var bandToleranceBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + colors[4] + ".png");
              m_bandToleranceLoader.load(bandToleranceBitmap);
            }
        }
            
		public function setColorBands_old(bandValues:Vector.<int>, toleranceValue:Number)
		{
			//assigns a value into bandThreeColor based on random number
			bandOneColor = bandColorMap[bandValues[0]];
			bandTwoColor = bandColorMap[bandValues[1]];
			bandThreeColor = bandColorMap[bandValues[2]];
			if (m_bandCount > 4)
				bandFourColor = bandColorMap[bandValues[3]];
			
			switch(toleranceValue)
			{
				case 0.01:
					bandToleranceColor="grey";
					break;
				case 0.1:
					bandToleranceColor="violet";
					break;
				case 0.25:
					bandToleranceColor="blue";
					break;
				case 0.5:
					bandToleranceColor="green";
					break;
				case 1:
					bandToleranceColor="brown";
					break;
				case 2:
					bandToleranceColor="red";
					break;
				case 5:
					bandToleranceColor="gold";
					break;
				case 10:
					bandToleranceColor="silver";
					break;
				default:
					break;
			}
			//trace(randnum_tolerance);
			
			const toleranceBandName:String = (m_bandCount > 4) ? "band5" : "band4";
			
			var bandObject:Sprite;
			if (m_bandOneLoader != null) {
				bandObject = Sprite(this.getChildByName("band1"));
				bandObject.removeChild(m_bandOneLoader);
			}
			if (m_bandTwoLoader != null) {
				bandObject = Sprite(this.getChildByName("band2"));
				bandObject.removeChild(m_bandTwoLoader);
			}
			if (m_bandThreeLoader != null) {
				bandObject = Sprite(this.getChildByName("band3"));
				bandObject.removeChild(m_bandThreeLoader);
			}
			if (m_bandFourLoader != null) {
				bandObject = Sprite(this.getChildByName("band4"));
				bandObject.removeChild(m_bandFourLoader);
			}
			if (m_bandToleranceLoader != null) {
				bandObject = Sprite(this.getChildByName(toleranceBandName));
				bandObject.removeChild(m_bandToleranceLoader);
			}
		
			//load image into Band1
			m_bandOneLoader = new Loader(); 
			Sprite(this.getChildByName("band1")).addChild(m_bandOneLoader); 
			var bandOneBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/t_" + bandOneColor + ".png"); 
			m_bandOneLoader.load(bandOneBitmap); 
			
			//load image into Band2
			m_bandTwoLoader = new Loader(); 
			Sprite(this.getChildByName("band2")).addChild(m_bandTwoLoader); 
			var bandTwoBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + bandTwoColor + ".png"); 
			m_bandTwoLoader.load(bandTwoBitmap); 
			
			//load image into Band3
			m_bandThreeLoader = new Loader(); 
			Sprite(this.getChildByName("band3")).addChild(m_bandThreeLoader); 
			var bandThreeBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + bandThreeColor + ".png"); 
			m_bandThreeLoader.load(bandThreeBitmap);
			
			//load image into Band4
			if (m_bandCount > 4 && this.getChildByName("band4") != null)
			{
				m_bandFourLoader = new Loader();
				Sprite(this.getChildByName("band4")).addChild(m_bandFourLoader);
				var bandFourBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + bandFourColor + ".png");
				m_bandFourLoader.load(bandFourBitmap);
			}
			
			//load image into Tolerance Band
			m_bandToleranceLoader = new Loader();
			Sprite(this.getChildByName(toleranceBandName)).addChild(m_bandToleranceLoader);
			var bandToleranceBitmap:URLRequest = new URLRequest(m_pngBandSuffix + "/s_" + bandToleranceColor + ".png");
			m_bandToleranceLoader.load(bandToleranceBitmap);
		}
		
		
		private function probeLeft_handler(event:MouseEvent):void
		{	
            trace('ENTER ResistorBase#probeLeft_handler');
									
			var hotspot1Left_minX:Number = (parent).x + resistorTipLeftX;
			var hotspot1Left_maxX:Number = (parent).x + resistorTipLeftX + getChildByName("resistorEndLeft").width;
			var hotspot1Left_minY:Number = (parent).y + (resistorTipLeftY - 35);
			var hotspot1Left_maxY:Number = (parent).y + (resistorTipLeftY + 5);
			
			var redProbe_tipX = (parent).x + MovieClip(parent).probe_red.x;
			var redProbe_tipY = (parent).y + MovieClip(parent).probe_red.y;
			
			var blackProbe_tipX = (parent).x + MovieClip(parent).probe_black.x;
			var blackProbe_tipY = (parent).y + MovieClip(parent).probe_black.y;

			var probeBlackTempLocation:String = null;
			var probeRedTempLocation:String = null;

	
		///TEST FOR PROBES ON LEFT SIDE RESISTOR
			if (  (redProbe_tipX > hotspot1Left_minX && redProbe_tipX < hotspot1Left_maxX) 
				&& (redProbe_tipY > hotspot1Left_minY && redProbe_tipY < hotspot1Left_maxY)
				&& probeOnLeft == false )  
			{
				sndClickIt=new clickit3();
				sndClickItChannel=sndClickIt.play(); 
				transform1.volume=.75;
				sndClickItChannel.soundTransform=transform1;
				probeOnLeft = true;
				redProbeOnLeft = true;
				localProbeRedLeftLocation = this.resistorLeftCoordinates;
				this.getChildByName("probe_engaged_left").alpha = 1;	
			}
//			
//			//No Action - Probe Already Engaged
			else if (  (redProbe_tipX > hotspot1Left_minX && redProbe_tipX < hotspot1Left_maxX) 
				&& (redProbe_tipY > hotspot1Left_minY && redProbe_tipY < hotspot1Left_maxY)
				&& probeOnLeft == true )
				
			{ 
				probeOnLeft = true;
				redProbeOnLeft = true;
				this.getChildByName("probe_engaged_left").alpha = 1;
			}
			
			else 
			{
				redProbeOnLeft = false;
				localProbeRedLeftLocation = null;
				//this.getChildByName("probe_engaged_right").alpha = 0;
			}
				
			if ((blackProbe_tipX > hotspot1Left_minX && blackProbe_tipX < hotspot1Left_maxX) 
				&& (blackProbe_tipY > hotspot1Left_minY && blackProbe_tipY < hotspot1Left_maxY)
				&& probeOnLeft == false )
			{
				sndClickIt=new clickit3();
				sndClickItChannel=sndClickIt.play(); 
				transform1.volume=.75;
				sndClickItChannel.soundTransform=transform1;
				probeOnLeft = true;
				blackProbeOnLeft = true;
				localProbeBlackLeftLocation = this.resistorLeftCoordinates;
				this.getChildByName("probe_engaged_left").alpha = 1;	
			}
			
//			//Sound Off Probe already engaged
			else if ((blackProbe_tipX > hotspot1Left_minX && blackProbe_tipX < hotspot1Left_maxX) 
				&& (blackProbe_tipY > hotspot1Left_minY && blackProbe_tipY < hotspot1Left_maxY)
				&& probeOnLeft == true ) 
			{
				probeOnLeft = true;
				blackProbeOnLeft = true;
				this.getChildByName("probe_engaged_left").alpha = 1;
			}
				
			else 
			{
				blackProbeOnLeft = false;
				localProbeBlackLeftLocation = null;
			}	
					
			if (blackProbeOnLeft == false && redProbeOnLeft == false)
			{
				probeOnLeft = false;
				this.getChildByName("probe_engaged_left").alpha = 0;
			}
		}
		
		
		private function probeRight_handler(event:MouseEvent):void
		{	
			var hotspot1Right_minX:Number = (parent).x + resistorTipRightX - getChildByName("resistorEndRight").width;
			var hotspot1Right_maxX:Number = (parent).x + resistorTipRightX;
			var hotspot1Right_minY:Number = (parent).y + (resistorTipRightY - 35);
			var hotspot1Right_maxY:Number = (parent).y + (resistorTipRightY + 5);
			//trace(hotspot1Right_minX + hotspot1Right_maxX);
			
			var redProbe_tipX = (parent).x + MovieClip(parent).probe_red.x;
			var redProbe_tipY = (parent).y + MovieClip(parent).probe_red.y;
			
			var blackProbe_tipX = (parent).x + MovieClip(parent).probe_black.x;
			var blackProbe_tipY = (parent).y + MovieClip(parent).probe_black.y;
			
			var probeBlackTempLocation:String = null;
			var probeRedTempLocation:String = null;

	
		//  TEST FOR PROBES ON RIGHT SIDE OF RESISTOR
			
			if (  (redProbe_tipX > hotspot1Right_minX && redProbe_tipX < hotspot1Right_maxX) 
				&& (redProbe_tipY > hotspot1Right_minY && redProbe_tipY < hotspot1Right_maxY)
				&& probeOnRight == false )
			{
				sndClickIt=new clickit3();
				sndClickItChannel=sndClickIt.play(); 
				transform1.volume=.75;
				sndClickItChannel.soundTransform=transform1;
				probeOnRight = true;
				redProbeOnRight = true;
				localProbeRedRightLocation = this.resistorRightCoordinates;
				//trace(this.resistorRightCoordinates);
				this.getChildByName("probe_engaged_right").alpha = 1;
			} 
			
			//Probe already engaged Sound Off
			else if (  (redProbe_tipX > hotspot1Right_minX && redProbe_tipX < hotspot1Right_maxX) 
				&& (redProbe_tipY > hotspot1Right_minY && redProbe_tipY < hotspot1Right_maxY)
				&& probeOnRight == true )
				
			{ 
				probeOnRight = true;
				redProbeOnRight = true;
				this.getChildByName("probe_engaged_right").alpha = 1;
			}
			
			else 
			{
				redProbeOnRight = false;
				localProbeRedRightLocation = null;
				//this.getChildByName("probe_engaged_right").alpha = 0;
			}
				
				
			if ( (blackProbe_tipX > hotspot1Right_minX && blackProbe_tipX < hotspot1Right_maxX) 
				&& (blackProbe_tipY > hotspot1Right_minY && blackProbe_tipY < hotspot1Right_maxY)
				&& probeOnRight == false)
			{
				sndClickIt=new clickit3();
				sndClickItChannel=sndClickIt.play(); 
				transform1.volume=.75;
				sndClickItChannel.soundTransform=transform1;
				probeOnRight = true;
				blackProbeOnRight = true;
				localProbeBlackRightLocation = this.resistorRightCoordinates;
				this.getChildByName("probe_engaged_right").alpha = 1;
			}
				
			// No Action -- Probe Engaged
			else if ( (blackProbe_tipX > hotspot1Right_minX && blackProbe_tipX < hotspot1Right_maxX) 
				&& (blackProbe_tipY > hotspot1Right_minY && blackProbe_tipY < hotspot1Right_maxY)
				&& probeOnRight == true ) 
			{
				probeOnRight = true;
				blackProbeOnRight = true;
				//probeBlackTempLocation = this.resistorRightCoordinates;
				this.getChildByName("probe_engaged_right").alpha = 1;
			}
				
			else 
			{
				blackProbeOnRight = false;
				localProbeBlackRightLocation = null;
				//this.getChildByName("probe_engaged_right").alpha = 0;
			}
			
			if (blackProbeOnRight == false && redProbeOnRight == false)
			{
				probeOnRight = false;
				this.getChildByName("probe_engaged_right").alpha = 0;
			}
		}
		
		
		
		private function probeLocationAssignment_handler(event:MouseEvent):void
		
		{
			if (localProbeRedLeftLocation != null)
			{
				Globe.probeRedLocation = localProbeRedLeftLocation;
			}
			
			else if (localProbeRedRightLocation != null)
			{
				Globe.probeRedLocation = localProbeRedRightLocation;
			}
			
			if (localProbeBlackLeftLocation != null)
			{
				Globe.probeBlackLocation = localProbeBlackLeftLocation;
			}
			
			else if (localProbeBlackRightLocation != null)
			{
				Globe.probeBlackLocation = localProbeBlackRightLocation;
			}
			
			//if (localProbeRedLeftLocation == null && localProbeRedRightLocation == null )
//			{
//				Globe.probeRedLocation = null;
//			}
//			
//			if (localProbeBlackLeftLocation == null && localProbeBlackRightLocation == null )
//			{
//				Globe.probeBlackLocation = null;
//			}
		}
		
//		private function probeQuery_handler(event:MouseEvent):void
//		{
//			if ( redProbeOnLeft == true || blackProbeOnLeft == true || redProbeOnRight == true || blackProbeOnRight == true) 
//			{
//				trace("black probe on " + Globe.probeBlackLocation);
//				trace("red probe on " + Globe.probeRedLocation);
//				//Globe.resistance = ExternalInterface.call('breadModel', 'query', 'voltage', Globe.probeBlackLocation + ',' + Globe.probeRedLocation, '200k');
//			}
//		}
		
		
		
		////////////////////////////////
		
		private function resistor_rollovers_right_handler(event:Event):void
		{
			var hotspot1Right_minX:Number = (parent).x + resistorTipRightX - getChildByName("resistorEndRight").width;
			var hotspot1Right_maxX:Number = (parent).x + resistorTipRightX;
			var hotspot1Right_minY:Number = (parent).y + (resistorTipRightY - 35);
			var hotspot1Right_maxY:Number = (parent).y + (resistorTipRightY + 5);
		
			var redProbe_tipX = (parent).x + MovieClip(parent).probe_red.x;
			var redProbe_tipY = (parent).y + MovieClip(parent).probe_red.y;
			
			var blackProbe_tipX = (parent).x + MovieClip(parent).probe_black.x;
			var blackProbe_tipY = (parent).y + MovieClip(parent).probe_black.y;
			
			if (     (redProbe_tipX > hotspot1Right_minX && redProbe_tipX < hotspot1Right_maxX) 
				&& (redProbe_tipY > hotspot1Right_minY && redProbe_tipY < hotspot1Right_maxY)
				&& probeOnRight == false  
				||   (blackProbe_tipX > hotspot1Right_minX && blackProbe_tipX < hotspot1Right_maxX) 
				&& (blackProbe_tipY > hotspot1Right_minY && blackProbe_tipY < hotspot1Right_maxY)
				&& probeOnRight == false )
			{
				this.getChildByName("resistor_rollover_right").alpha = 1;
			}
				
			else
			{
				this.getChildByName("resistor_rollover_right").alpha = 0;
			}
			
		}
		
		///////////////////////////
		
		private function resistor_rollovers_left_handler(event:Event):void{
			
			var hotspot1Left_minX:Number = (parent).x + resistorTipLeftX;
			var hotspot1Left_maxX:Number = (parent).x + resistorTipLeftX + getChildByName("resistorEndLeft").width;
			var hotspot1Left_minY:Number = (parent).y + (resistorTipLeftY - 35);
			var hotspot1Left_maxY:Number = (parent).y + (resistorTipLeftY + 5);
		
			
			var redProbe_tipX = (parent).x + MovieClip(parent).probe_red.x;
			var redProbe_tipY = (parent).y + MovieClip(parent).probe_red.y;
			
			var blackProbe_tipX = (parent).x + MovieClip(parent).probe_black.x;
			var blackProbe_tipY = (parent).y + MovieClip(parent).probe_black.y;
			
			if (     (redProbe_tipX > hotspot1Left_minX && redProbe_tipX < hotspot1Left_maxX) 
				&& (redProbe_tipY > hotspot1Left_minY && redProbe_tipY < hotspot1Left_maxY)
				&& probeOnLeft == false  
				||   (blackProbe_tipX > hotspot1Left_minX && blackProbe_tipX < hotspot1Left_maxX) 
				&& (blackProbe_tipY > hotspot1Left_minY && blackProbe_tipY < hotspot1Left_maxY)
				&& probeOnLeft == false )
			{
				this.getChildByName("resistor_rollover_left").alpha = 1;
			}
				
			else
			{
				this.getChildByName("resistor_rollover_left").alpha = 0;
			}
		}
	
	//NOTES
	//enter values because resistor is smaller on screen yet program looks at true values 
	//var hotspotWidth:Number = 12;
	//var hotspotHeight:Number = 3.4;
	//var resistorBodyWidth:Number = 43;
	//resistor rollover left x = .8
	//resistor rollover left y = 7.3
	//resistor rollover right x = 
	//hard code rollover and resistorTip values based on resistor width of 67
	//use resistor_sm.fla for guidance - set size to desired size of resistor
	//use testResistorTips to tweak resistorTip x and y values
	
		
	}
}