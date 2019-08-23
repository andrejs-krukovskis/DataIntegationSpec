trigger CloseProject on opportunity (after insert, after update) {
    for (opportunity op : [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity, Opportunity.Account 
                                    WHERE (ID in trigger.new) AND (Type = 'New Project') AND (stage = 'Closed Won')]) {

    }
}