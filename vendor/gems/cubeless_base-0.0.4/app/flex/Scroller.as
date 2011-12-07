package{
	import mx.events.ChildExistenceChangedEvent;
	import mx.core.UIComponent;
	import mx.containers.HBox;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.external.ExternalInterface;

	public class Scroller {

		private var timer:Timer = new Timer(10);
		public var _target:HBox;
		public var _enableScrollOn:Number;
		public var _speed:Number;
		public var _isScrolling:Boolean;
		private var _paused:Boolean = false;

		public function set paused(b:Boolean):void {
			if (b) stopScrolling(null);
			_paused = b;
		}

		public function Scroller(scrollable:HBox){
			_target = scrollable;
		}

		public function startScrolling(speed:Number, scrollFunction:Function, event:Event):void {
			if (_paused || (_isScrolling && speed==_speed)) return;
			_speed = speed;
			if(timer.running){
				timer.stop();
			}
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, scrollFunction);
			timer.start();
			_isScrolling = true;

		}

		public function scrollRight(event:TimerEvent):void{
			_target.horizontalScrollPosition += _speed;
		}

		public function scrollLeft(event:TimerEvent):void{
			_target.horizontalScrollPosition -= _speed;
		}

		public function stopScrolling(event:MouseEvent):void {
			if(_paused || !_isScrolling){return};
			_isScrolling = false;
			if(timer.running) {
				timer.stop();
			}
		}

		public function logarithmicScroller(event:MouseEvent) {
			//!H
			if (event.stageY<=30) {
				stopScrolling(event);
				return;
			}
			var rightZoneStart:int = event.currentTarget.width*0.56;
			var leftZoneEnd:int = event.currentTarget.width*0.44;
			var coord:int = event.stageX;
			if (coord>=rightZoneStart) {
				var bucket_size:int = leftZoneEnd/4;
				var speed:int = 1+(coord-rightZoneStart)/bucket_size;
				speed = (1+Math.log(speed))*speed;
				startScrolling(speed, this.scrollRight, event);
			} else if (coord<=leftZoneEnd) {
				var bucket_size:int = leftZoneEnd/4;
				var speed:int = 1+(leftZoneEnd-coord)/bucket_size;
				speed = (1+Math.log(speed))*speed;
				startScrolling(speed, this.scrollLeft, event);
			} else {
				stopScrolling(event);
			}
		}
	}
}