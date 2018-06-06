/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({
	doInit : function(cmp, e, helper) {
        helper.returnApprovals(cmp,e);
	},
    
    handleComponentEvent : function(cmp,e,helper) {
        if(e.getParam('reloadCmp')) {
            var spinner = cmp.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            helper.returnApprovals(cmp,e);   
        }
    }
})