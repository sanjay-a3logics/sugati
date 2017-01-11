/**
 *  @Author         :   Naval Sharma
 *  @Date           :   4-March-2016
 *  @Description    :   Test class for "Triggers"
 * 
 * */
 
@isTest
public class PostInstallClassTest{
    
    /*** Test various operations of PostInstallClass ****/
    static testMethod void TestPostInstall(){
    
        PostInstallClass postinstall = new PostInstallClass();
        Test.testInstall(postinstall,  null);
        Test.testInstall(postinstall,  new Version(1, 0));
    }    
}