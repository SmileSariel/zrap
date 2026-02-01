// webapp/ext/controller/Refresh.controller.js
sap.ui.define([
	'sap/ui/core/mvc/ControllerExtension',
	'sap/m/MessageToast',
	'sap/base/Log',
	'sap/ui/core/util/File'
], function (ControllerExtension, MessageToast, Log, File) {
	'use strict';

	return ControllerExtension.extend('com.hcq.excel.ext.controller.Refresh', {
		constructor: function () {
			this._uploadOperationInProgress = false;
		},

		override: {
			onInit: function () {
				var oExtensionAPI = this.base.getExtensionAPI();

				var oModel = oExtensionAPI.getModel();

				if (oModel && oModel.oRequestor && typeof oModel.oRequestor.request === 'function') {
					this._setupModelMonitoring(oModel);
				} else {
					// 如果通过 extension API 获取不到模型，尝试从视图获取
					setTimeout(() => {
						var viewModel = this.getView().getModel();
						if (viewModel && viewModel.oRequestor && typeof viewModel.oRequestor.request === 'function') {
							this._setupModelMonitoring(viewModel);
						}
					}, 1000);
				}
			}
		},

		_setupModelMonitoring: function (oModel) {
			var that = this;
			var originalRequest = oModel.oRequestor.request;

			oModel.oRequestor.request = function (method, path) {
				// 检测 fileUpload 操作
				if (arguments.length > 1 && typeof path === 'string' && path.includes('fileUpload')) {
					Log.info("Detected fileUpload operation: " + method + " " + path);
					that._uploadOperationInProgress = true;

					var result = originalRequest.apply(this, arguments);

					if (result && typeof result.then === 'function') {
						result.then(function (response) {
							that._refreshData(true);
						}).catch(function (error) {
							// 根据错误类型，决定是否显示错误消息
							if (_isSystemError(error)) {
								let errorMessage = "Upload failed";
								if (error && typeof error === 'object') {
									if (error.message) {
										errorMessage = error.message;
									} else if (error.responseText) {
										try {
											const errorObj = JSON.parse(error.responseText);
											errorMessage = errorObj.error?.message?.value || error.responseText;
										} catch (parseError) {
											errorMessage = error.responseText;
										}
									}
								} else if (typeof error === 'string') {
									errorMessage = error;
								}

								MessageToast.show("Upload failed: " + errorMessage);
							} else {
								// 业务错误或警告，默认，只记录日志，不显示错误消息
								Log.info("fileUpload operation completed with business warnings/errors", error);
							}

							// 即使有错误也刷新数据，以显示最新状态
							that._refreshData(false);
						});
					} else {
						that._refreshData(true);
					}
					return result;
				}
				// 检测 fileDownload 操作
				else if (arguments.length > 1 && typeof path === 'string' && path.includes('fileDownload')) {
					Log.info("Detected fileDownload operation: " + method + " " + path);
					var result = originalRequest.apply(this, arguments);

					if (result && typeof result.then === 'function') {
						result.then(function (response) {
							const nameParts = response.fileName.split('.');
							const fileExtension = nameParts.length > 1 ? nameParts.pop() : 'xlsx';
							const binaryData = _convertBase64(response.fileContent);
							const uint8Array = Uint8Array.from(atob(binaryData), (c) => c.charCodeAt(0));
							const blob = new Blob([uint8Array], { type: response.mimeType });

							File.save(
								blob,
								nameParts,
								fileExtension,
								response.mimeType
							);

							MessageToast.show("Template downloaded successfully");
						}).catch(function (error) {
							Log.error("Template download failed", error);

							if (_isSystemError(error)) {
								let errorMessage = "Download failed";
								if (error && typeof error === 'object') {
									if (error.message) {
										errorMessage = error.message;
									} else if (error.responseText) {
										try {
											const errorObj = JSON.parse(error.responseText);
											errorMessage = errorObj.error?.message?.value || error.responseText;
										} catch (parseError) {
											errorMessage = error.responseText;
										}
									}
								} else if (typeof error === 'string') {
									errorMessage = error;
								}

								MessageToast.show("Download failed: " + errorMessage);
							}
						});
					}
					return result;
				}
				return originalRequest.apply(this, arguments);
			};
		},

		_refreshData: function (operationSuccess) {
			var oModel = this.getView().getModel();

			if (oModel && oModel.oRequestor && typeof oModel.oRequestor.request === 'function') {
				if (oModel.hasPendingChanges()) {
					oModel.resetChanges();
				}

				oModel.refresh();

				if (operationSuccess) {
					MessageToast.show("Data refreshed after upload");
				}
			} else {
				Log.error("Could not get OData V4 model for refresh");
			}
		},
	});

	function _convertBase64(urlSafeBase64) {
		let standardBase64 = urlSafeBase64.replace(/[^A-Za-z0-9+/=_\-]/g, "");

		standardBase64 = standardBase64.replace(/-/g, "+").replace(/_/g, "/");

		const paddingLength = 4 - (standardBase64.length % 4);
		if (paddingLength !== 4) {
			standardBase64 += "=".repeat(paddingLength);
		}

		return standardBase64;
	};

	function _isSystemError(error) {
		// 检查错误对象是否有特定的系统错误标识，从而为系统错误
		if (!error) {
			return false;
		}

		// 检查错误消息中是否包含系统错误关键词
		const systemErrorKeywords = [
			'network', 'timeout', 'server', 'connection', '500', '400', '401', '403', '404',
			'Internal Server Error', 'Bad Request', 'Unauthorized', 'Forbidden'
		];

		let errorMessage = '';
		if (typeof error === 'string') {
			errorMessage = error.toLowerCase();
		} else if (typeof error === 'object' && error.message) {
			errorMessage = error.message.toLowerCase();
		} else if (typeof error === 'object' && error.responseText) {
			errorMessage = error.responseText.toLowerCase();
		}

		return systemErrorKeywords.some(keyword =>
			errorMessage.includes(keyword.toLowerCase())
		);
	}
});