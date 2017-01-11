/**
*  @Author         :   Naval Sharma
*  @Date           :   25-Feb-2016
*  @Description    :   Test class for "Countries"
* 
**/

@isTest
class CountriesTest{
    
   
    
    /** Test various operations of Countries **/
    static testMethod void countriesTest1(){
        Countries IFDS = new Countries();   
        Countries.loadCountries();
    }
}