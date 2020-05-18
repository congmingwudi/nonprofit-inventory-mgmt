global without sharing class GearOrder_UpdateContact {

    // called from the New Gear Order flow.
    // the reason for this method is only for the 'without sharing' policy so that the unauthenticated site user 
    // under whom the New Gear Order flow runs will be able to update fields on the Contact object (ie. MobilePhone)
    
    @InvocableMethod(label='Update Contact')    
    global static List<Contact> updateContact(List<Contact> contacts) {
        
        System.debug('GearOrder_UpdateContact - contacts to update: ' + contacts); 
        update contacts;
        System.debug('GearOrder_UpdateContact - contacts updated: ' + contacts); 
        
        return contacts;
        
    } // end updateContact   
    
} // end GearOrder_UpdateContact