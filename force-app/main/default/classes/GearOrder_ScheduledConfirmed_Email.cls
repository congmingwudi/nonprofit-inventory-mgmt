global class GearOrder_ScheduledConfirmed_Email implements Messaging.InboundEmailHandler {
	  
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		
        System.debug('GearOrder_ScheduledConfirmed_Email > handleInboundEmail - email: ' + email); 
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		return result;
        
	} // end handleInboundEmail

} // end GearOrder_ScheduledConfirmed_Email