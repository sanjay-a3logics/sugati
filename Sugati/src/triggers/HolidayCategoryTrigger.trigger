trigger HolidayCategoryTrigger on Category__c (before insert) {
		if(Pro_UE__c.getInstance().Category__c){
            for(Category__c cat : trigger.New){
				cat.addError('you cannot create category');
			}
        }     
}