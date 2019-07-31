/*
 Copyright 2017 Dave Alden/Working Edge Ltd.

 Licensed under MIT.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of
 the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

package cordova.plugin;
import android.os.Build.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;

public class ClearData extends CordovaPlugin
{
    private static final String ACTION_CACHE = "cache";

    private ClearData self;

    private CallbackContext callbackContext;

    /**
     * Constructor.
     */
    public ClearData() {}

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute (String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try {
            self = this;
            this.callbackContext = callbackContext;

            if( action.equals(ACTION_CACHE) ) {
                clearCache();
            }else{
                handleError("Unknown plugin action: " + action);
                return false;
            }
            return true;
        } catch (Exception e) {
            handleException(e);
            return false;
        }
    }

    private void clearCache(){
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                try {
                    if (VERSION_CODES.KITKAT <= VERSION.SDK_INT) {
                        ((ActivityManager)context.getSystemService(ACTIVITY_SERVICE))
                                .clearApplicationUserData(); // note: it has a return value!
                    }else {
                        self.webView.clearCache();
                    }
                    sendPluginSuccess();
                } catch (Exception e) {
                    handleException(e);
                }
            }
        });
    }

    private void sendPluginSuccess(){
        PluginResult result = new PluginResult(PluginResult.Status.OK);
        result.setKeepCallback(false);
        callbackContext.sendPluginResult(result);
    }

    private void handleError(String msg){
        callbackContext.error(msg);
    }

    private void handleException(Exception e){
        String msg = e.getMessage();
        msg = "Exception occurred: ".concat(msg);
        handleError(msg);
    }
}