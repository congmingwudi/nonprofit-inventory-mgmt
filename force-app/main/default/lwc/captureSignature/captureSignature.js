/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement,api,track } from 'lwc';
import saveSign from '@salesforce/apex/SignatureHelper.saveSign';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//declaration of variables for calculations
let isDownFlag, 
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;            
       
let x = "#0000A0"; //blue color
let y = 1.5; //weight of line width and dot.       

let canvasElement, ctx; //storing canvas context
let attachment; //holds attachment information after saving the sigture on canvas
let dataURL,convertedDataURI; //holds image data

export default class CapturequestedEventignature extends LightningElement {
    
    // public properties
    @api recordId;
    @api errorMessage

    @track signatureSaved;
 
    //event listeners added for drawing the signature within shadow boundary
    constructor() {
        super();
        this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));
    }

    //retrieve canvase and context
    renderedCallback(){
        canvasElement = this.template.querySelector('canvas');
        ctx = canvasElement.getContext("2d");
    }
    
    //handler for mouse move operation
    handleMouseMove(event){
        this.searchCoordinatesForEvent('move', event);      
    }
    
    //handler for mouse down operation
    handleMouseDown(event){
        this.searchCoordinatesForEvent('down', event);         
    }
    
    //handler for mouse up operation
    handleMouseUp(event){
        this.searchCoordinatesForEvent('up', event);       
    }

    //handler for mouse out operation
    handleMouseOut(event){
        this.searchCoordinatesForEvent('out', event);         
    }

    get isSignatureSaved() {
        return this.signatureSaved;
    }

    get isError() {
        return (this.errorMessage != null) && (this.errorMessage !== '');
    }
    
    /*
        handler to perform save operation.
        save signature as attachment.
        after saving shows success or failure message as toast
    */
    handleSaveClick(){   
        console.log('captureSignature > handleSaveClick');

        //set to draw behind current content
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(0,0,canvasElement.width, canvasElement.height); 

        //convert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        
        //call Apex method imperatively and use promise for handling success & failure
        saveSign({strSignElement: convertedDataURI,recId : this.recordId})
            .then(result => {
                console.log('captureSignature > handleSaveClick - signature saved');
                //this.ContentDocumentLink = result;
                //console.log('ContentDocumentId: ' + this.ContentDocumentLink.ContentDocumentId);               

                // show success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Signature Saved',
                        variant: 'success',
                    }),
                );

                this.signatureSaved = true;

                // DOM event to be received by parent aura components
                const value = true;
                const event = new CustomEvent("signatureSavedEvent", {
                    detail: { value }
                });
                // fire event
                this.dispatchEvent(event);
            })
            .catch(error => {
                console.log('captureSignature > handleSaveClick - error: ' + JSON.stringify(error));

                //show error message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Salesforce File record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });        
     
    } // end handleSaveClick

    //clear the signature from canvas
    handleClearClick(){
        console.log('captureSignature > handleClearClick');

        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height); 
        this.signatureSaved = false;

        // DOM event to be received by parent aura components
        const value = false;
        const event = new CustomEvent("signatureSavedEvent", {
            detail: { value }
        });
        // fire event
        this.dispatchEvent(event);  

    } // end handleClearClick

    searchCoordinatesForEvent(requestedEvent, event){
        event.preventDefault();
        if (requestedEvent === 'down') {
            this.setupCoordinate(event);           
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    //This method is primary called from mouse down & move to setup cordinates.
    setupCoordinate(eventParam){
        //get size of an element and its position relative to the viewport 
        //using getBoundingClientRect which returns left, top, right, bottom, x, y, width, height.
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX -  clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

    //For every mouse move based on the coordinates line to redrawn
    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
        ctx.lineWidth = y;        
        ctx.closePath(); //create a path from current point to starting point
        ctx.stroke(); //draws the path
    }
    
    //this draws the dot
    drawDot(){
        ctx.beginPath();
        ctx.fillStyle = x; //blue color
        ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
        ctx.closePath();
    }
    
}