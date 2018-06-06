/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({
	returnApprovals : function(cmp,e) {
		var action = cmp.get('c.getApprovalsList');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var spinner = cmp.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            if(cmp.isValid() && state == 'SUCCESS') {
                cmp.set('v.myApprovals', response.getReturnValue());
                if(response.getReturnValue().length == 0) {
                    $A.util.removeClass(cmp.find("noItems"), "slds-hide");
                    $A.util.addClass(cmp.find("theTable"), "slds-hide");
                }
            } else {
                var failToast = $A.get("e.force:showToast");
                failToast.setParams({
                    "type": "error",
                    "message": "Failed to return Approval Items."
                });
                failToast.fire();
            }
        });
        $A.enqueueAction(action);
    }
})