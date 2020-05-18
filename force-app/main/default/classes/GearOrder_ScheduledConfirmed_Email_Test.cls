@isTest
private class GearOrder_ScheduledConfirmed_Email_Test {

    @isTest static void test_handleInboundEmail() {
        System.debug('GearOrder_ScheduledConfirmed_Email_Test > test_handleInboundEmail');
        
		// create email and envelope object.
       	Messaging.InboundEmail email = new Messaging.InboundEmail();
       	Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    	
       	email.subject = 'test';
       	envelope.fromAddress = 'ryan.cox@salesforce.com';
    
       	// test
       	GearOrder_ScheduledConfirmed_Email handler = new GearOrder_ScheduledConfirmed_Email();
		Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
        System.debug('GearOrder_ScheduledConfirmed_Email_Test > test_handleInboundEmail - result: ' + result);
        
    } // end test_handleInboundEmail
    
    
} // end GearOrder_ScheduledConfirmed_Email_Test