public without sharing class CalculateWeekClass {

//function to avoid Trigger Recursion
     public static boolean firstRun = true;
     public static boolean RunOnce()
        {
        
            if (firstRun)
            {
            firstRun = false;
            }
            else
            {
            return firstRun;
            }
            return true;
        }
    
   
    
    
    public void calculateBWeek (set<string> ids, decimal OrigBWeekDay){
             
        List<Opportunity> Opp1 = [select id,Name,StageName,O_Booking_Week__c,O_Booking_Date__c,O_Booking_Week_Actual__c
                                from Opportunity
                                  where id in: ids]; 
                                  
                                  
        
         system.debug('Displaying Opportunity Details' + Opp1[0].id);
         system.debug('Displaying Opportunity Details' + Opp1[0].Name);
         system.debug('Displaying Opportunity Details ' + Opp1[0].O_Booking_Week__c); 
        if(opp1[0].O_Booking_Date__c != null){
        

            integer Byear= opp1[0].O_Booking_Date__c.year();
     
            //Create first January of the year 
            string BfirstJanuary = '01/01/' + string.valueOf(opp1[0].O_Booking_Date__c.year());
        
            System.debug('First January ' + BfirstJanuary); 
   
            
            Date Bdt = Date.parse(BfirstJanuary); //Find what will be the day for 1st January of the Booking year. 
            
            system.debug('First January ' + String.valueOf(Bdt)); 
            
            DateTime dt1 =DateTime.newInstance(Bdt, Time.newInstance(0, 0, 0, 0));
            
            String BdayOfWeek=dt1.format('EEEE');
            
            system.debug('BDay ' + String.valueOf(BdayOfWeek)); 
            system.debug('BWEEKDay ' + String.valueOf(OrigBWeekDay)); 
            
            Date Bookingdate = opp1[0].O_Booking_Date__c;
            Datetime BookingDT = (DateTime)Bookingdate;
            String BookingdayOfWeek = BookingDT.format('EEEE');
            
            system.debug('BookingDay ' + String.valueOf(BookingdayOfWeek)); 
            
            
            // Calculate Booking Week     
            if (BdayOfWeek == 'Sunday' || BdayOfWeek == 'Monday' || BdayOfWeek == 'Tuesday' ) 
            {
            system.debug('day-sun mon tue');
            Opp1[0].O_Booking_Week__c = Opp1[0].O_Booking_Week_Actual__c;
            
            if(BookingdayOfWeek == 'Sunday')
            
            {
            system.debug('book sun');
            Opp1[0].O_Booking_Week__c = Opp1[0].O_Booking_Week_Actual__c - 1;
            }
            
            
            }
            else
            {
            system.debug('day -w,thur');
            Opp1[0].O_Booking_Week__c = Opp1[0].O_Booking_Week_Actual__c - 1;
            
            if(BookingdayOfWeek == 'Sunday')
            {
            system.debug('book sun');
            Opp1[0].O_Booking_Week__c = Opp1[0].O_Booking_Week_Actual__c - 2;
            
            system.debug('Displaying Opportunity Details' + Opp1[0].O_Booking_Week__c); 
            
            }
            
            
            }
            
            if ((Opp1[0].O_Booking_Week__c) == 0)
            {
            Opp1[0].O_Booking_Week__c = 1;
            }
            
            
            
            if (Opp1[0].O_Booking_Week__c >52  )
            {
            Opp1[0].O_Booking_Week__c = 52;
            
            }
            //System.assert(false,Opp1[0]);
            
            system.debug('Displaying Opportunity Details' + Opp1[0].O_Booking_Week__c); 
            
            update Opp1;
            
       }           
}
    
  public void calculateEWeek (set<string> ids,  decimal OrigEWeekDay)
    {
             
        List<Opportunity> Opp1 = [select id,Name,StageName,
                                    CloseDate,O_Enquiry_Week__c,O_Enquiry_Week_Actual__c
                                
                                  from Opportunity
                                  where id in: ids]; 
                                  
                                  
        
         system.debug('Displaying Opportunity Details' + Opp1[0].id);
         system.debug('Displaying Opportunity Details' + Opp1[0].Name);
        
         system.debug('Displaying Opportunity Details ' + Opp1[0].O_Enquiry_Week__c); 
    
           
           if(opp1[0].CloseDate != null){
               integer Eyear= opp1[0].CloseDate.year();
         
          
               
                //Create first January of the year 
           
             string EfirstJanuary = '01/01/' + string.valueOf(opp1[0].CloseDate.year());
          
            
             system.debug('First January ' + EfirstJanuary);
           
            Date Edt = Date.parse(EfirstJanuary); //Find what will be the day for 1st January of the Booking year.
             system.debug('First January ' + String.valueOf(Edt));
       
            DateTime dt2 =DateTime.newInstance(Edt, Time.newInstance(0, 0, 0, 0));
     
            String EdayOfWeek=dt2.format('EEEE');
            
    
             system.debug('EDay ' + String.valueOf(EdayOfWeek)); 
             system.debug('EWEEKDay ' + String.valueOf(OrigEWeekDay));
      
             Date Enquirydate = opp1[0].CloseDate;
            Datetime EnquiryDT = (DateTime)Enquirydate;
            String EnquirydayOfWeek = EnquiryDT.format('EEEE');
            
        
            system.debug('BookingDay ' + String.valueOf(EnquirydayOfWeek)); 
            
                   
                  //Calculate Enquiry Week
                  
                  
                   if (EdayOfWeek == 'Sunday' || EdayOfWeek == 'Monday' || EdayOfWeek == 'Tuesday' ) 
                {
                    system.debug('day-sun mon tue');
                   Opp1[0].O_Enquiry_Week__c = Opp1[0].O_Enquiry_Week_Actual__c;
                   
                   if(EnquirydayOfWeek == 'Sunday')
                   
                    {
                        system.debug('book sun');
                    Opp1[0].O_Enquiry_Week__c = Opp1[0].O_Enquiry_Week_Actual__c - 1;
                    }
          
                    
                }
                else
                {
                    system.debug('day -w,thur');
                    Opp1[0].O_Enquiry_Week__c = Opp1[0].O_Enquiry_Week_Actual__c - 1;
                    
                    if(EnquirydayOfWeek == 'Sunday')
                        {
                            system.debug('book sun');
                         Opp1[0].O_Enquiry_Week__c = Opp1[0].O_Enquiry_Week_Actual__c - 2;
                        
                         system.debug('Displaying Opportunity Details' + Opp1[0].O_Enquiry_Week__c); 
              
                        }
                    
                   
                }
                
                 if ((Opp1[0].O_Enquiry_Week__c) == 0)
                    {
                        Opp1[0].O_Enquiry_Week__c = 1;
                    }
                    
                
                
                    if (Opp1[0].O_Enquiry_Week__c >52  )
                    {
                      Opp1[0].O_Enquiry_Week__c = 52;
                        
                    }
                  
       
             
                system.debug('Displaying Opportunity Details' + Opp1[0].O_Enquiry_Week__c);
               
                
                update Opp1;
            }
            
                  
}
      
    
    
    
    public void calculateQWeek (set<string> ids, decimal OrigQWeekDay){
        
         List<Opportunity> Opp1 = [select id,Name,StageName,
                                    O_Quote_Date__c,O_Quote_Week__c,O_Quote_Week_Actual__c
                                  from Opportunity
                                  where id in: ids]; 
                                  
                                  
        
         system.debug('Displaying Opportunity Details' + Opp1[0].id);
         system.debug('Displaying Opportunity Details' + Opp1[0].Name);
        
         system.debug('Displaying Opportunity Details ' + Opp1[0].O_Quote_Week__c); 
   
           
           integer Qyear= opp1[0].O_Quote_Date__c.year();

            //Create first January of the year 
         
         string QfirstJanuary = '01/01/' + string.valueOf(opp1[0].O_Quote_Date__c.year());  
         
         system.debug('First January ' + QfirstJanuary);
 
        Date Qdt = Date.parse(QfirstJanuary); //Find what will be the day for 1st January of the Booking year.
        
    
          system.debug('First January ' + String.valueOf(Qdt));
    
        DateTime dt3 =DateTime.newInstance(Qdt, Time.newInstance(0, 0, 0, 0));
        

        
        String QdayOfWeek=dt3.format('EEEE');

         
         system.debug('QDay ' + String.valueOf(QdayOfWeek)); 
         system.debug('QWEEKDay ' + String.valueOf(OrigQWeekDay));
         
           

         Date Quotedate = opp1[0].O_Quote_Date__c;
        Datetime QuoteDT = (DateTime)Quotedate;
        String QuotedayOfWeek = QuoteDT.format('EEEE');
        
        
        
        system.debug('BookingDay ' + String.valueOf(QuotedayOfWeek)); 
            
               // Calculate Quote Week   
                
             if (QdayOfWeek == 'Sunday' || QdayOfWeek == 'Monday' || QdayOfWeek == 'Tuesday' ) 
            {
                system.debug('day-sun mon tue');
               Opp1[0].O_Quote_Week__c = Opp1[0].O_Quote_Week_Actual__c;
               
               if(QuotedayOfWeek == 'Sunday')
               
                {
                    system.debug('book sun');
                Opp1[0].O_Quote_Week__c = Opp1[0].O_Quote_Week_Actual__c - 1;
                }
      
                
            }
            else
            {
                system.debug('day -w,thur');
                Opp1[0].O_Quote_Week__c = Opp1[0].O_Quote_Week_Actual__c - 1;
                
                if(QuotedayOfWeek == 'Sunday')
                    {
                        system.debug('book sun');
                     Opp1[0].O_Quote_Week__c = Opp1[0].O_Quote_Week_Actual__c - 2;
                    
                     system.debug('Displaying Opportunity Details' + Opp1[0].O_Quote_Week__c); 
          
                    }
                
               
            }
            
             if ((Opp1[0].O_Quote_Week__c) == 0)
                {
                    Opp1[0].O_Quote_Week__c = 1;
                }
                
            
            
                if (Opp1[0].O_Quote_Week__c >52  )
                {
                  Opp1[0].O_Quote_Week__c = 52;
                    
                }
                
            system.debug('Displaying Opportunity Details' + Opp1[0].O_Quote_Week__c);
            
            update Opp1;
            
        
    }
    
    
}