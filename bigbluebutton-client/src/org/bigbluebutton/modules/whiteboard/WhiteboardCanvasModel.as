package org.bigbluebutton.modules.whiteboard
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;	
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;	
	import org.bigbluebutton.common.IBbbCanvas;
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.core.managers.UserManager;
	import org.bigbluebutton.main.events.MadePresenterEvent;
	import org.bigbluebutton.modules.whiteboard.business.shapes.DrawGrid;
	import org.bigbluebutton.modules.whiteboard.business.shapes.DrawObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.GraphicFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.GraphicObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.ShapeFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.TextObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.WhiteboardConstants;
	import org.bigbluebutton.modules.whiteboard.events.GraphicObjectFocusEvent;
	import org.bigbluebutton.modules.whiteboard.events.PageEvent;
	import org.bigbluebutton.modules.whiteboard.events.ToggleGridEvent;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardDrawEvent;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardSettingResetEvent;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardUpdate;
	import org.bigbluebutton.modules.whiteboard.views.AnnotationIDGenerator;
	import org.bigbluebutton.modules.whiteboard.views.IDrawListener;
	import org.bigbluebutton.modules.whiteboard.views.PencilDrawListener;
	import org.bigbluebutton.modules.whiteboard.views.TextDrawListener;
	import org.bigbluebutton.modules.whiteboard.views.WhiteboardCanvas;
	import org.bigbluebutton.modules.whiteboard.views.models.WhiteboardTool;
	
    /**
    * Class responsible for handling actions from presenter and sending annotations to the server.
    */
	public class WhiteboardCanvasModel {
		private var _wbCanvas:WhiteboardCanvas;	      
        private var drawListeners:Array = new Array();
        private var wbTool:WhiteboardTool = new WhiteboardTool();
        private var shapeFactory:ShapeFactory = new ShapeFactory();
		private var idGenerator:AnnotationIDGenerator = new AnnotationIDGenerator();
		
		/* represents the max number of 'points' enumerated in 'segment' before 
		sending an update to server. Used to prevent spamming red5 with unnecessary packets */
		private var sendShapeFrequency:uint = 30;	
		
		/* same as above, except a faster interval may be desirable when erasing, for aesthetics */
		private var sendEraserFrequency:uint = 20;	

		private var width:Number;
		private var height:Number;
        
        public function set wbCanvas(canvas:WhiteboardCanvas):void {
            _wbCanvas = canvas;
            drawListeners.push(new PencilDrawListener(idGenerator, _wbCanvas, sendShapeFrequency, shapeFactory));
            drawListeners.push(new TextDrawListener(idGenerator, _wbCanvas, sendShapeFrequency, shapeFactory));
        }
        
        public function zoomCanvas(width:Number, height:Number):void {
            shapeFactory.setParentDim(width, height);	
            this.width = width;
            this.height = height;	
        }
        
		public function changeFontStyle(font:String):void {
			wbTool._fontStyle = font;	
		}
		
		public function changeFontSize(size:Number):void {
			wbTool._fontSize = size;
		}
        
        public function onKeyDown(event:KeyboardEvent):void {
            for (var ob:int = 0; ob < drawListeners.length; ob++) {
                (drawListeners[ob] as IDrawListener).ctrlKeyDown(event.ctrlKey);
            }
        }        

        public function onKeyUp(event:KeyboardEvent):void {
            for (var ob:int = 0; ob < drawListeners.length; ob++) {
                (drawListeners[ob] as IDrawListener).ctrlKeyDown(event.ctrlKey);
            }
        }
        
		public function doMouseUp(mouseX:Number, mouseY:Number):void {
//            LogUtil.debug("CanvasModel doMouseUp ***");
            for (var ob:int = 0; ob < drawListeners.length; ob++) {
                (drawListeners[ob] as IDrawListener).onMouseUp(mouseX, mouseY, wbTool);
            }
		}
				       		
		public function doMouseDown(mouseX:Number, mouseY:Number):void {
//            LogUtil.debug("*** CanvasModel doMouseDown");
            for (var ob:int = 0; ob < drawListeners.length; ob++) {
                (drawListeners[ob] as IDrawListener).onMouseDown(mouseX, mouseY, wbTool);
            }
		}
				
		public function doMouseMove(mouseX:Number, mouseY:Number):void {
            for (var ob:int = 0; ob < drawListeners.length; ob++) {
                (drawListeners[ob] as IDrawListener).onMouseMove(mouseX, mouseY, wbTool);
            }
		}
				
		public function setGraphicType(type:String):void {
//            LogUtil.debug("!!! Set graphic type = " + type);
			wbTool.graphicType = type;
		}
		
		public function setTool(s:String):void {
//            LogUtil.debug("!!!! Set graphic tool = " + s);
			wbTool.toolType = s;
		}
		
		public function changeColor(color:uint):void {
            wbTool.drawColor = color;
		}
					
		public function changeThickness(thickness:uint):void {
            wbTool.thickness = thickness;
		}

        /** Helper method to test whether this user is the presenter */
        private function get isPresenter():Boolean {
            return UserManager.getInstance().getConference().amIPresenter();
        }
	}
}
