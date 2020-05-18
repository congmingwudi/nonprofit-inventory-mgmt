@isTest
private class GearOrder_CreateContactTest {

    @isTest static void test_createContact() {
        
        List<Contact> contacts = new List<Contact>();
        Contact con = new Contact(
            FirstName = 'Ryan', LastName = 'Cox', Email = 'ryan@test.com', MobilePhone = '720-982-5916'
        );
        contacts.add(con);
            
        GearOrder_CreateContact.createContact(contacts);
        
    } // end test_createContact
    
} // end GearOrder_CreateContactTest