@isTest
private class GearOrder_UpdateContactTest {

    @isTest static void test_updateContact() {
        
        // insert contacts
        List<Contact> contacts = new List<Contact>();
        Contact con = new Contact(
            FirstName = 'Ryan', LastName = 'Cox', Email = 'ryan@test.com', MobilePhone = '333-333-3333'
        );
        contacts.add(con);
        
        insert contacts;
        System.debug('GearOrder_UpdateContactTest > test_updateContact - created: ' + contacts); 
        
        // update contacts
        List<Contact> updatedContacts = new List<Contact>();
        Contact updatedContact = new Contact();        
        updatedContact.Id = contacts.get(0).Id;
        updatedContact.MobilePhone = '720-982-5916';
        updatedContacts.add(updatedContact);
            
        GearOrder_UpdateContact.updateContact(updatedContacts);
        
    } // end test_updateContact
    
} // end GearOrder_UpdateContactTest