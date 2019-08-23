public with sharing class ProjectCalloutService {
    public static Http http = new Http();

    @InvocableMethod(label='PostOpportunityToPMS')
    public static void PostOpportunityToPMS(List<ID> ops) {
        List<Opportunity> OppsToUpdate = new List<Opportunity>();
        for (opportunity op : [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity, Opportunity.Account WHERE ID in :ops]) {
            SendOp(op);
            OppsToUpdate.add(op);
        }
        update OppsToUpdate;
    }

    public static Opportunity SendOp(Opportunity op) {
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('token', GetSecToken());
            request.setBody(GenerateOppJSON(op));
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 201) {
                op.StageName = 'Submitted Project';
            } else {
                op.StageName = 'Resubmit Project';
            }
            return op;
    }
    public static string GetSecToken() {
        ServiceTokens__c token = ServiceTokens__c.getValues('ProjectServiceToken');
        if (token == null) {
            return 'error getting token... But you\'re probably just testing anyway :)';
        }
        return token.Token__c;
    }
    public static string GenerateOppJSON(Opportunity op) {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('opportunityId', op.ID);
        gen.writeStringField('opportunityName', op.Name);
        gen.writeStringField('accountName', op.Account.Name);
        gen.writeStringField('closeDate', op.CloseDate.Year() + '-' + op.CloseDate.Month() + '-' + op.CloseDate.Day());
        gen.writeNumberField('amount', op.Amount);  

        return gen.getAsString();
    }
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts { 
        List<Opportunity> OppsToWork;
        public QueueablePMSCall(List<Opportunity> opps) {
            this.OppsToWork = opps;
        }
        public void execute(QueueableContext context) {
            List<Opportunity> OppsToUpdate = new List<Opportunity>();
            for (Opportunity op : this.OppsToWork) {
                SendOp(op);
                OppsToUpdate.add(op);
            }
            update OppsToUpdate;
        }
    }

}
