//定义全局变量
var globalVar = new function() {
	// 参数
	this.crCrdAplID = ""; // 请求参数-信用卡申请编号
	this.aplyPcsgSN = ""; // 请求参数-申请处理序号
	this.cCAplAudtLnkTpCd = ""; // 请求参数-信用卡申请稽核环节类型代码
	this.callLnkTpCd = ""; // 请求参数-拨打环节类型代码

	this.jsonData = {}; // 请求参数-json对象

	// 弹出窗口
	this.appInfoImageWin = null; // 弹出窗口-影像资料
	this.inBnkInfoWin = null; // 弹出窗口-行内信息协查
	this.crsChckRsltWin = null; // 弹出窗口-交叉检查结果
	this.outBnkPsnInfoWin = null; // 弹出窗口-行外信息协查(个人)
	this.outBnkOrgInfoWin = null; // 弹出窗口-行外信息协查(企业)
	this.bocReptWin = null; // 弹出窗口-人行征信报告
	this.loclReptWin = null; // 弹出窗口-地方协查
	this.phoneCallWin = null; // 弹出窗口-拨打电话
	this.creditRefusalReasonWin = null; // 弹出窗口-选择拒绝原因
	this.creditCompensateContentWin = null; // 弹出窗口-选择待补件原因

	// 控件引用
	this.phoneCallInfoGridGlobal = null; // 控件-电话外呼记录列表
};

PJF.html.bodyReady(function() {

	// 请求参数-信用卡申请编号
	// var crCrdAplID = PJF.html.getUrlParam("crCrdAplID");
	var crCrdAplID = "123456789012345678";
	globalVar.crCrdAplID = crCrdAplID;
	// 请求参数-申请处理序号
	// var aplyPcsgSN = PJF.html.getUrlParam("aplyPcsgSN");
	var aplyPcsgSN = "098765432109876";
	globalVar.aplyPcsgSN = aplyPcsgSN;
	// 请求参数-信用卡申请稽核环节类型代码
	// var cCAplAudtLnkTpCd = PJF.html.getUrlParam("cCAplAudtLnkTpCd");
	var cCAplAudtLnkTpCd = "17"; // 参考代码表——信用卡申请稽核环节类型代码
	globalVar.cCAplAudtLnkTpCd = cCAplAudtLnkTpCd;
	// 请求参数-拨打环节类型代码
	// var callLnkTpCd = PJF.html.getUrlParam("callLnkTpCd");
	var callLnkTpCd = "16"; // 参考代码表——拨打环节类型代码
	globalVar.callLnkTpCd = callLnkTpCd;

	// 定义各个交易的请求json对象
	globalVar.jsonData = {
		"crCrdAplID" : crCrdAplID,
		"aplyPcsgSN" : aplyPcsgSN,
		"cCAplAudtLnkTpCd" : cCAplAudtLnkTpCd,
		"callLnkTpCd" : callLnkTpCd
	};

	// 征信调查-电话外呼内嵌代码start
	var _phoneCallInfoGrid;

	// 查询电话记录列表记录参数
	var phoneCallInfoParam = {
		url : PJF.constants.DEFAULT_ACTION,
		queryParams : {
			"_fw_service_id" : "simpleTransaction",
			"transaction_id" : "A06731234",
			"jsonData" : PJF.util.json2str(globalVar.jsonData),
			"adapterId" : "ecpJson"
		}
	};

	// ***以上各个环节页面一致***

	// 征信调查结论-start
	// 核实方式
	// var _veryfyMethod=new PJF.ui.checkbox({
	// dom: "veryfyMethod",
	// name: "veryfyMethod",
	// labels : [ "自助短信","电话","其他" ],
	// values : [ "1","2","3" ],
	// count : 3
	// });

	var _radio1 = new PJF.ui.radio({
		dom : 'radio1',
		name : 'radio1',
		values : [ '0' ],
		labels : [ '通过' ],
		required : false,
		handler : function() {
			_radio2.unSelected();
			_radio3.unSelected();
			_Lv1SplmtAplRsnIdBtn.disable();
			_Lv1RjRsBtn.disable();
		}
	});

	var _radio2 = new PJF.ui.radio({
		dom : 'radio2',
		name : 'radio2',
		values : [ '1' ],
		labels : [ '拒绝' ],
		required : false,
		handler : function() {
			_radio1.unSelected();
			_radio3.unSelected();
			_Lv1RjRsBtn.enable();
			_Lv1SplmtAplRsnIdBtn.disable();
		}
	});

	var _radio3 = new PJF.ui.radio({
		dom : 'radio3',
		name : 'radio3',
		values : [ '2' ],
		labels : [ '待补件' ],
		required : false,
		handler : function() {
			_radio1.unSelected();
			_radio2.unSelected();
			_Lv1SplmtAplRsnIdBtn.enable();
			_Lv1RjRsBtn.disable();
		}
	});

	var _Lv1RjRsBtn = new PJF.ui.linkButton({
		dom : "Lv1RjRsBtn",
		name : "选择",
		onclick : function() {
			globalVar.creditRefusalReasonWin = new PJF.ui.window({
				dom : "Lv1RjRsBtnWin",
				title : "选择拒绝原因",
				width : 400,
				height : 400,
				url : "creditRefusalReasonQuery.jsp"
			});
		}
	});
	
	_Lv1RjRsBtn.disable();
	
	var _Lv1SplmtAplRsnIdBtn = new PJF.ui.linkButton({
		dom : "Lv1SplmtAplRsnIdBtn",
		name : "选择",
		onclick : function() {
			if (globalVar.creditCompensateContentWin) {
				globalVar.creditCompensateContentWin.destroy();
				globalVar.creditCompensateContentWin = null;
			}
			globalVar.creditCompensateContentWin = new PJF.ui.window({
				dom : "LvlSplmtAplRsnID",
				title : "选择待补件",
				width : 320,
				height : 340,
				url : "creditCompensateContentQuery.jsp",
				cache : false
			});

		}
	});
	
	_Lv1SplmtAplRsnIdBtn.disable();
	
	var _CrSurvyPosOpinDsc = new PJF.ui.textfield({
		dom : "CrSurvyPosOpinDsc",
		datatype : 'multi',
		width : '568px',
		height : '100px',
		overflow : 'auto',
		invalidMessage : '输入长度不正确！',
		inputType : "help",
		missingMessage : "在这里输入信息",
		maxfont : 50,
		required : true
	});
	// 选择待补件
	var _lv1SplmtAplRDsc = new PJF.ui.textfield({
		dom : "lv1SplmtAplRDsc",
		id : "lv1SplmtAplRDsc",
		width : 130,
		readOnly : true
	});

	var _lvl2SplmtAplRDsc = new PJF.ui.textfield({
		dom : "lvl2SplmtAplRDsc",
		id : "lvl2SplmtAplRDsc",
		width : 130,
		readOnly : true
	});
	// 选择拒绝原因
	// 一级拒绝原因描述
	var _lv1RjRsDsc = new PJF.ui.textfield({
		dom : "lv1RjRsDsc",
		id : "lv1RjRsDsc",
		width : 130,
		readOnly : true
	});
	// 二级拒绝原因描述
	var _lvl2RjRsDsc = new PJF.ui.textfield({
		dom : "lvl2RjRsDsc",
		id : "lvl2RjRsDsc",
		width : 130,
		readOnly : true
	});
	// 一级补件编号
	var _lv1SplmtAplRsnID = new PJF.ui.textfield({
		dom : "lv1SplmtAplRsnID",
		id : "lv1SplmtAplRsnID",
		width : 130
	});
	// 二级补件编号
	var _lvl2SplmtAplRsnID = new PJF.ui.textfield({
		dom : "lvl2SplmtAplRsnID",
		id : "lvl2SplmtAplRsnID",
		width : 130
	});
	// 一级拒绝原因编号
	var _lv1RjRsID = new PJF.ui.textfield({
		dom : "lv1RjRsID",
		id : "lv1RjRsID",
		width : 130
	});
	// 二级拒绝原因编号
	var _lvl2RjRsID = new PJF.ui.textfield({
		dom : "lvl2RjRsID",
		id : "lvl2RjRsID",
		width : 130
	});

	loadCreditConclusion();
	
	// 加载征信调查结论信息，各个环节自行修改此方法
	function loadCreditConclusion() {
		PJF.communication.cpsJsonReq({
			// jsonData : PJF.util.json2str(globalVar.jsonData),
			fwServiceId : "simpleTransaction",
			fwTranId : "A06731245",
			success : function(data) {
				var arry = [ '1', '2', '3', '4', '5' ];
				var arry2 = [];
				var arry3 = [];
				// 已核实项目
				var alrdyVrfyPrjIdrArry = data.Alrdy_Vrfy_Prj_Idr;
				for ( var i = 0; i < alrdyVrfyPrjIdrArry.length; i++) {
					arry2.push(alrdyVrfyPrjIdrArry.charAt(i));
				}
				for ( var j = 0; j < arry2.length; j++) {
					if (arry2[j] == 1) {
						arry3.push(j + 1)
					}

				}

				var arryCCAplCrVrfyMtdCd = [ '1', '2', '3' ];
				var arry2CCAplCrVrfyMtdCd = [];
				var arry3CCAplCrVrfyMtdCd = [];
				var cCAplCrVrfyMtdCdArry = data.CCApl_Cr_Vrfy_MtdCd;
				for ( var a = 0; a < cCAplCrVrfyMtdCdArry.length; a++) {
					arry2CCAplCrVrfyMtdCd.push(cCAplCrVrfyMtdCdArry.charAt(a));
				}
				for ( var b = 0; b < arry2CCAplCrVrfyMtdCd.length; b++) {
					if (arry2CCAplCrVrfyMtdCd[b] == 1) {
						arry3CCAplCrVrfyMtdCd.push(b + 1)
					}

				}
				
				// 已核实项目
				var _alrdyVrfyPrjIdr = new PJF.ui.checkbox({
					dom : 'alrdyVrfyPrjIdr',
					name : 'alrdyVrfyPrjIdr',
					labels : [ '办卡意愿', '本人签名', '单位信息', '联系方式', '其它' ],
					values : [ '1', '2', '3', '4', '5' ],
					count : 5,
					selected : arry3,
					handler : function() {
					}
				});
				
				_lvl2RjRsDsc.setValue(data.Lvl2_RjRs_Dsc);
				_lv1RjRsDsc.setValue(data.Lv1_RjRs_Dsc);
				_lvl2SplmtAplRDsc.setValue(data.Lvl2SplmtAplRDsc);
				_lv1SplmtAplRDsc.setValue(data.Lv1_SplmtApl_RDsc);
				_CrSurvyPosOpinDsc.setValue(data.CCApl_Cr_Opin_Dsc);
				_lv1SplmtAplRsnID.setValue(data.Lv1_SplmtApl_Rsn_ECD);
				_lvl2SplmtAplRsnID.setValue(data.Lvl2_SplmtApl_Rsn_ECD);
				_lv1RjRsID.setValue(data.Lv1_RjRs_ID);
				_lvl2RjRsID.setValue(data.Lvl2_RjRs_ID);
				if (data.CCApl_Cr_Cnclsn_Cd == '1') {
					_radio1.setSelected(0);
				} else if (data.CCApl_Cr_Cnclsn_Cd == '2') {
					_radio2.setSelected(1);
					_Lv1RjRsBtn.enable();
				} else if (data.CCApl_Cr_Cnclsn_Cd == '3') {
					_radio3.setSelected(2);
					_lv1SplmtAplRsnIdBtn.enable();
				}

			},
			failure : function(responseData) {
				new PJF.ui.errorMessageBox({
					title : "查询征信调查结论失败",
					desc : responseData.BK_DESC,
					code : responseData.BK_CODE,
					traceId : responseData.evtTraceId
				});
			}
		});
	}
	// 征信调查结论-end

	// 人工征信到此为止

	// 查询征信调查结论

	// 保存
	new PJF.ui.linkButton({
		dom : "btnSave",
		name : "保存",
		onclick : function() {

			var jsonData = PJF.html.getAreaData("credfrom");
			jsonData.alrdyVrfyPrjIdr = jsonData.alrdyVrfyPrjIdr + ",";
			jsonData.OprECD = "1212";
			jsonData.crCrdAplID = globalVar.crCrdAplID;
			if (PJF.html.validateForm("credfrom")) {
				if (_radio1.getValue() != 0 && _radio2.getValue() != 1
						&& _radio3.getValue() != 2) {
					new PJF.ui.messageBox({
						style : "warning",
						title : "错误信息",
						content : "请勾选审核结果"
					});
					return false;
				}

				if (_radio2.getValue() == 1) {
					if (_lv1RjRsDsc.getValue() == "") {
						new PJF.ui.messageBox({
							style : "warning",
							title : "错误信息",
							content : "请选择拒绝原因"
						});
						return false;
					}

				}

				if (_radio3.getValue() == 2) {
					if (_lv1SplmtAplRDsc.getValue() == "") {
						new PJF.ui.messageBox({
							style : "warning",
							title : "错误信息",
							content : "请选择待补件内容"
						});
						return false;
					}

				}
				if (_radio1.getValue() == "0") {
					jsonData.cCAplCrCnclsnCd = _radio1.getValue();
				}
				if (_radio2.getValue() == "1") {
					jsonData.cCAplCrCnclsnCd = _radio2.getValue();
				}
				if (_radio3.getValue() == "2") {
					jsonData.cCAplCrCnclsnCd = _radio3.getValue();
				}

				PJF.communication.cpsJsonReq({
					jsonData : PJF.util.json2str(jsonData),
					fwServiceId : "simpleTransaction",
					fwTranId : "A06731237",
					success : function(respData) {
						new PJF.ui.messageBox({
							style : 'success',
							title : '保存征信调查结论',
							content : '修改成功',
							fn : function(){
								turnToCreditByMan();
							},
							onClose : function(){
								turnToInvestConclusion();
							}
						});
					},
					failure : function(responseData) {
						new PJF.ui.errorMessageBox({
							title : "保存失败",
							desc : responseData.BK_DESC,
							code : responseData.BK_CODE,
							traceId : responseData.evtTraceId
						});
					}
				});

			}

		}
	});

	/*
	 * 
	 * 用途: 根据报文返回的多选框值，读取选中的项 原理： 报文返回结果为0-1序列，11010表示第1,2,4项被选中 输入项： 多选框取值 返回值：
	 * 多选框被选中项对应的取值，数组结果
	 */
	function getCheckBoxValue(retValue) {
		var checkBoxVal = new Array();

		var startPosition = 0;
		var index = retValue.indexOf("1", startPosition);
		var i = 0;
		while (index != -1) {
			checkBoxVal[i++] = (index + 1) + "";
			startPosition = index + 1;
			index = retValue.indexOf("1", startPosition);
		}

		return checkBoxVal;
	}
	
	//返回到页面
	function turnToInvestConclusion(){
		var pageName = "";
	}
	//跳转到基础页面
	function turnToCreditByMan(){
		var pageName = "";
	}
	
});