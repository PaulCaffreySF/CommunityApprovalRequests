global with sharing class ApprovalListCnt {
        
    @AuraEnabled
    public static List<Map<String, Object>> getApprovalsList() {
        List<Map<String,Object>> returnList = new List<Map<String,Object>>();
        Map<String,Schema.SObjectField> stepMap = Schema.SObjectType.ProcessInstanceStep.fields.getMap();
        
        String[] fieldsToCheck = new String[] {'Id', 'ProcessInstanceId','CreatedDate'};
            String[] fieldsToCheck2 = new String[] {'Status', 'TargetObjectId'};
                Map<String,Schema.SObjectField> m1 = Schema.SObjectType.ProcessInstanceWorkItem.fields.getMap();
        Map<String,Schema.SObjectField> m2 = Schema.SObjectType.ProcessInstance.fields.getMap();
        for(String field : fieldsToCheck) {
            if( ! m1.get(field).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
                return null;
            }
        } 
        for(String f : fieldsToCheck2) {
            if( ! m2.get(f).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
                return null;
            }
        } 
        
        List<ProcessInstanceWorkItem> wItems = [SELECT ProcessInstance.Status,ProcessInstance.TargetObjectId,Id,CreatedDate,ProcessInstance.ProcessDefinition.TableEnumOrId 
                                                FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status = 'Pending']; 
        
        List<String> objNames = new List<String>();
        for(ProcessInstanceWorkItem piw : wItems) {
            objNames.add(piw.ProcessInstance.ProcessDefinition.TableEnumOrId);
        }
        
        List<FieldDefinition> fieldDef =  [SELECT EntityDefinitionId,QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName 
                                           IN :objNames AND IsNameField = TRUE];
        List<ProcessInstanceStep> steps = [SELECT Comments,ProcessInstanceId FROM ProcessInstanceStep WHERE StepStatus = 'Started' AND ProcessInstance.Status = 'Pending'];
        
        for(ProcessInstanceWorkItem i : wItems) {
            Map<String, Object> m = new Map<String, Object>();
            String comment = '';
            for(ProcessInstanceStep s : steps) {
                if(i.ProcessInstanceId == s.ProcessInstanceId) {
                    comment = s.Comments;
                    break;
                }
            }
            String nameField;
            for(FieldDefinition fd : fieldDef) {
                if(fd.EntityDefinitionId == i.ProcessInstance.ProcessDefinition.TableEnumOrId) {
                    nameField = fd.QualifiedApiName;
                    break;
                }
            }
            
            Schema.SObjectType p = i.ProcessInstance.TargetObjectId.getSObjectType();
            String objectName = String.valueOf(p); 
            String objectId = i.ProcessInstance.TargetObjectId;

            String queryStr = 'SELECT ' + nameField +' FROM ' + objectName + ' WHERE Id = :objectId LIMIT 1';
            sObject result = Database.query(queryStr);
            String relatedTo = String.valueOf(result.get(nameField));
            
            m.put('WorkItemId',i.Id);
            m.put('RelatedTo',relatedTo);
            m.put('Id',i.ProcessInstance.TargetObjectId);
            m.put('Status',i.ProcessInstance.Status);
            m.put('CreatedDate',i.CreatedDate);
            m.put('Comment', comment);
            m.put('ObjectType', objectName);
            returnList.add(m);
        }
        return returnList;
    }
    
    @AuraEnabled
    global static String acceptRequest(String reqId, String comment) {
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(comment);
            req.setAction('Approve');
            req.setWorkitemId(reqId);
            Approval.ProcessResult result = Approval.process(req);
            return 'success';
        } catch (Exception e) {
            System.debug(e);
            return 'failure';
        }
    }
    
    @AuraEnabled
    global static String declineRequest(String reqId, String comment) {
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(comment);
            req.setAction('Reject');
            req.setWorkitemId(reqId);
            Approval.ProcessResult result = Approval.process(req);
            return 'success';
        } catch (Exception e) {
            System.debug(e);
            return 'failure';
        }
    }
    
    @deprecated
    global static List<ProcessInstanceWorkItem> getApprovals() { return new List<ProcessInstanceWorkItem>(); }
    
    @deprecated
    global static String[] getObjectInfo(ProcessInstanceWorkItem obj) { return new String[]{}; }
}