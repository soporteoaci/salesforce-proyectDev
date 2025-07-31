({
  doInit: function(component, event, helper) {      
      
    helper.getprocessInstanceList(component);
  },
    
    
    redirectProcess: function (component, event, helper) {
     
        var processId= event.target.id;

    $A.get("e.force:navigateToURL").setParams({ 
       "url": "/detail/"+ processId
    }).fire();
}

    
    

})