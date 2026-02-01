sap.ui.define([
    "sap/m/MessageToast",
    "sap/ui/core/util/File",
    "sap/m/BusyDialog"
], function (MessageToast, File, BusyDialog) {
    'use strict';

    const progID = "ZTEST"; // Sample ProgID 

    return {
        /**
         * Generated event handler.
         *
         * @param oContext the context of the page on which the event was fired. `undefined` for list report page.
         * @param aSelectedContexts the selected contexts of the table rows.
         */
        onTemplateDownload: async function (oContext, aSelectedContexts) {
            let busyDialog;

            try {
                busyDialog = new BusyDialog({
                    title: "Downloading",
                    text: "Please wait while the template is being downloaded..."
                });
                busyDialog.open();

                const model = this._controller.getExtensionAPI().getModel('templateService');
                const url = this.getEditFlow().getAppComponent().getManifestObject().resolveUri(model.sServiceUrl);

                const getTokenResp = await fetch(url, {
                    method: "GET",
                    headers: {
                        "X-CSRF-Token": "Fetch", Accept: "application/json"
                    },
                    credentials: "same-origin"
                });

                const token = getTokenResp.headers.get("x-csrf-token");

                const downloadEndpoint = url + "ZRAP_C_TEMPLATE(Progid='" + progID + "',IsActiveEntity=true)/FileContent";
                const downloadResp = await fetch(downloadEndpoint, {
                    method: "GET",
                    headers: {
                        "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": token
                    },
                    credentials: "same-origin"
                });

                if (!downloadResp.ok) {
                    throw new Error(`HTTP error! status: ${downloadResp.status}`);
                }

                const blob = await downloadResp.blob();
                const contentDisposition = downloadResp.headers.get('content-disposition');
                let filename = "template.xlsx"; // default filename

                if (contentDisposition) {
                    const filenameMatch = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/);
                    if (filenameMatch && filenameMatch[1]) {
                        filename = filenameMatch[1].replace(/['"]/g, '');
                    }
                }

                const nameParts = filename.split('.');
                const fileExtension = nameParts.length > 1 ? nameParts.pop() : 'xlsx'; 

                File.save(
                    blob,
                    nameParts,
                    fileExtension,
                    downloadResp.headers.get('content-type') || 'application/octet-stream'
                );

                MessageToast.show("Template downloaded successfully!");

            } catch (error) {
                console.error("Download error:", error);
                MessageToast.show("Template download failed: " + error.message);
            } finally {
                if (busyDialog) {
                    busyDialog.close();
                    busyDialog.destroy();
                }
            }
        }
    };
});