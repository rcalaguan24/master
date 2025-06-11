public with sharing class MRPScheduler implements Schedulable{
    public void execute(SchedulableContext context) {
        MRPGenerator.generateMRP();  
    }
}