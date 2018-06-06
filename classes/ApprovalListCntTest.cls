@isTest
global with sharing class ApprovalListCntTest {
    
    @testSetup
    static void setup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            User u = [SELECT Name, UserRoleId FROM User WHERE Id = : UserInfo.getUserId()];
            if(u.UserRoleId == null) {
                u.UserRoleId = [SELECT Id FROM UserRole WHERE Name='CEO'].Id;
                update u;
            }
            
            Id p = [select id from profile where name='System Administrator'].id;
            Id r = [SELECT Id FROM UserRole WHERE Name='CEO'].Id;
            Account ac = new Account(name ='Approval Test Account') ;
            insert ac; 
            
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
            insert con;   
            
            User user = new User(alias = 'appTest', email='tester@approvalAppex.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 
                                 timezonesidkey='America/Los_Angeles', username='tester@approvalAppex.com');
            insert user;

        }
    }
    
    static testMethod void testGetApprovalsListCase() {
        User user = [SELECT id FROM User WHERE Alias = 'appTest'];
        User user2 = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
        Id uId = UserInfo.getUserId();
        
        Case c = new Case();
        c.Subject = 'Approval Test Case';
        insert c;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(c.id);
        req1.setSubmitterId(user.Id); 
        req1.setProcessDefinitionNameOrId('ApprovalTest');
        req1.setNextApproverIds(new ID[] {user2.Id});
        Approval.ProcessResult result = Approval.process(req1);
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        List<Map<String, Object>> testList = ApprovalListCnt.getApprovalsList();
        System.assert(!testList.isEmpty());
        System.assertEquals('Submitting request for approval.', testList[0].get('Comment'));
    }
    
    static testMethod void testacceptRequest() {
        User user = [SELECT id FROM User WHERE Alias = 'appTest'];
        User user2 = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
        Id uId = UserInfo.getUserId();
        System.runAs(user2) {

            Case c = new Case();
            c.Subject = 'Approval Test Case';
            insert c;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(c.id);
            req1.setSubmitterId(user.Id); 
            req1.setNextApproverIds(new ID[] {uId});
            
            Approval.ProcessResult result = Approval.process(req1);
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            String comment = 'Testing Approval';
            
            String returns = ApprovalListCnt.acceptRequest(newWorkItemIds.get(0), comment);
            System.assertEquals('success', returns);
        }
    }
    
    static testMethod void testAcceptRequestFail() {
        String comment = 'Testing Deline Approval';
        String returns = ApprovalListCnt.acceptRequest('nothing', comment);
        System.assertEquals('failure', returns);
    }
    
    static testMethod void testdeclineRequest() {
        Case c = new Case();
        insert c;
        User user1 = [SELECT Id FROM User WHERE Alias='PCaff'];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Declining request');
        req1.setObjectId(c.id);
        req1.setSubmitterId(user1.Id); 
        req1.setProcessDefinitionNameOrId('test');
        req1.setSkipEntryCriteria(true);
        
        Approval.ProcessResult result = Approval.process(req1);
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        String comment = 'Testing Deline Approval';
        
        String returns = ApprovalListCnt.declineRequest(newWorkItemIds.get(0), comment);
        System.assertEquals('success', returns);
    }
    
    static testMethod void testdeclineRequestFail() {
        String comment = 'Testing Deline Approval';
        String returns = ApprovalListCnt.declineRequest('nothing', comment);
        System.assertEquals('failure', returns);
    }   
    
    static testMethod void getApprovalsTest() {
        List<ProcessInstanceWorkItem> a = ApprovalListCnt.getApprovals();
    }
    
    static testMethod void getObjectInfoTest() {
        ProcessInstanceWorkItem obj = new ProcessInstanceWorkItem();
        String[] a = ApprovalListCnt.getObjectInfo(obj);
    }
}