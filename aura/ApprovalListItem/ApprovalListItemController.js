/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({
    navigateTo : function(cmp, e, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get("v.approval").Id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    handleAction : function(cmp, e, helper) {
        var modalBody;
        $A.createComponent("c:modalContent", { 
            'itemId' : cmp.get("v.approval").WorkItemId,
            'status' : e.getParam("value"),
            'reloadModal' : cmp.getReference('v.reload')
        }, function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLib').showCustomModal({
                    header: e.getParam("value"),
                    body: modalBody, 
                    showCloseButton: true,
                    closeCallback: function() {
                        var reloadEvent = cmp.getEvent("reloadEvent");
                        reloadEvent.setParams({
                            reloadCmp : cmp.get("v.reload") 
                        });
                        reloadEvent.fire();
                    }
                })
            }
        });
    }
})