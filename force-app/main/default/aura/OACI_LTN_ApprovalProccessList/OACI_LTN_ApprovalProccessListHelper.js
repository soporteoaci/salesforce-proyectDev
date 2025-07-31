({

  getprocessInstanceList: function(component) {
    var action = component.get('c.getProcessInstances');
    
    var self = this;
    action.setCallback(this, function(actionResult) {
     component.set('v.processInstances', actionResult.getReturnValue());
    });
    $A.enqueueAction(action);
  }
})