global class ProductSummary {

	public String productCategory {get;set;}        
	public String productName {get;set;}        
	public Decimal quantity {get;set;}        
	public List<OrderItemDetail> orderItemDetails {get;set;}
    
    global class OrderItemDetail {
        public Gear_Order_Demographic__c demographic { 
            get {
            	if (demographic == null) demographic = new Gear_Order_Demographic__c();
                return demographic;
        	} 
        	set;
        }
        
        public Gear_Order_Item__c orderItem {
            get {
            	if (orderItem == null) orderItem = new Gear_Order_Item__c();
                return orderItem;
        	} 
        	set;
        }
        
        public String demographicDisplay { 
            get {                
				String child = (demographic.Child_Gender__c == null) ? 'UNKNOWN' : demographic.Child_Gender__c;
                String gender = (demographic.Child_Age__c == null) ? 'UNKNOWN' : demographic.Child_Age__c;
                String ethnicity = (demographic.Child_Race_Ethnicity__c == null) ? 'UNKNOWN' : demographic.Child_Race_Ethnicity__c;
                return child + ' | ' + gender + ' | ' + ethnicity;                    
        	}
   		}
        
        public String orderItemDisplay { 
            get {
            	String value = '';
                if (orderItem.Season__c != null) value += 'Season: ' + orderItem.Season__c + '<br/>';
                if (orderItem.Clothing_Size__c != null) value += 'Clothing Size: ' + orderItem.Clothing_Size__c + '<br/>';
                if (orderItem.Diaper_Size__c != null) value += 'Diaper Size: ' + orderItem.Diaper_Size__c + '<br/>';
                if (orderItem.Diaper_Swim_Size__c != null) value += 'Diaper (Swim) Size: ' + orderItem.Diaper_Swim_Size__c + '<br/>';
                return value; 
        	}
   		}
    
        public String commentsDisplay { 
            get {
            	String value = '';
                if (demographic.Comment__c != null) value += demographic.Comment__c + '<br/>';
                if (orderItem.Comment__c != null) value += orderItem.Comment__c + '<br/>';
                return value;
        	}
   		}
        
    } // end OrderItemDetail
    
} // end ProductSummary