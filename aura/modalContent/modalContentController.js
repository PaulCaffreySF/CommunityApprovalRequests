/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({
    doInit : function(cmp, e, helper) {
        cmp.set('v.reloadModal',false);
    },
    
    approveItem : function(cmp, e, helper) {
        var action = cmp.get('c.acceptRequest');
        action.setParams({
            "reqId" : cmp.get("v.itemId"),
            "comment" : cmp.get('v.comment')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "message": "Approval successfully submitted."
                });
                toastEvent.fire();
                cmp.set('v.reloadModal',true);
                cmp.find("overlayLib2").notifyClose();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Approval submission failed."
                });
                toastEvent.fire();
                cmp.find("overlayLib2").notifyClose();
            }
        });
        $A.enqueueAction(action);
    },
    
    rejectItem : function(cmp, e, helper) {
        var action = cmp.get('c.declineRequest');
        action.setParams({
            "reqId" : cmp.get("v.itemId"),
            "comment" : cmp.get('v.comment')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "message": "Rejection successfully submitted."
                });
                toastEvent.fire();
                cmp.set('v.reloadModal',true);
                cmp.find("overlayLib2").notifyClose();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Rejection submission failed."
                });
                toastEvent.fire();
                cmp.find("overlayLib2").notifyClose();
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCancel : function(cmp, e, helper) {
        cmp.find("overlayLib2").notifyClose();
    }
})