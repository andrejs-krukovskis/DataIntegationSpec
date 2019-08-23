@isTest
public class ProjectCalloutServiceTest {
    @isTest
    public static void TestSucPMSCallout() {
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        Account a = new Account(Name = 'test');
        insert a;
        Opportunity op = New Opportunity(amount = 200, Name = 'Test', StageName = 'Closed Lost', type = 'New Project', AccountID = a.ID, CloseDate = date.today());
        
        insert op;
        ProjectCalloutService.PostOpportunityToPMS(new List<id>{op.id});
        Test.StopTest();
        op = [Select StageName From Opportunity WHERE ID = :op.ID];
        System.assertEquals('Submitted Project', op.StageName);
        
    }
    @isTest
    public static void TestFailPMSCallount() {
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        Account a = new Account(Name = 'test');
        insert a;
        Opportunity op = New Opportunity(amount = 200, Name = 'Test', StageName = 'Closed Lost', type = 'New Project', AccountID = a.ID, CloseDate = date.today());
        insert op; 
        
        ProjectCalloutService.PostOpportunityToPMS(new List<id>{op.id});
        Test.StopTest();
        op = [Select StageName From Opportunity WHERE ID = :op.ID];
        System.assertEquals('Resubmit Project', op.StageName);
    }
}
