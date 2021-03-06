<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="p" uri="/PJFTag"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="<%=request.getContextPath() %>/script/jsloader.js"></script>
<script type="text/javascript" src="crSurvyIssue.js"></script>
<title>征信调查结论</title>
</head>

<body>
<!-- pjf_content每一个模块的最外层容器-->
<div class="pjf_content">
	
	<!-- 征信查询及结论块 -->
	<div class="pjf_content_three">
		<div class="div_ulbox">
			<div id="creditInvestPanel">
				
				<div class="pjf_ul_title_box">
					<h3 class="pjf_ul_title">征信调查结论</h3>
				</div>
				
				
		<form id="credfrom">
		<div class="div_ulbox">
			<ul class="pjf_ul_three">
				<li><label class="pjf_label">已核实项目：</label>
				<span id="alrdyVrfyPrjIdr" ></span></li>
			</ul>
		</div>
		<div class="div_ulbox">
			<ul class="pjf_ul_three">
				<li><label class="pjf_label">&nbsp;</label><span  id="radio1" ></span>
				</li>
				
			</ul>
			
			<ul class="pjf_ul_three">
				<li><label class="pjf_label">&nbsp;</label><span  id="radio2" ></span></li>
				<li><label class="pjf_label">拒绝原因</label>
				<input type="text" id="lv1RjRsDsc" name="lv1RjRsDsc"/>
				<input type="text" id="lvl2RjRsDsc" name="lvl2RjRsDsc"/>
				<input type="hidden" id="lv1RjRsID" name="lv1RjRsID"/>
				<input type="hidden" id="lvl2RjRsID" name="lvl2RjRsID"/>
				<input type="hidden" id="cCAplCrCnclsnCd" name="cCAplCrCnclsnCd"/>
				<span id="Lv1RjRsBtn" ></span></li>
			</ul>
			
			<ul class="pjf_ul_three">
				<li><label class="pjf_label">&nbsp;</label><span  id="radio3" ></span></li>
				<li><label class="pjf_label">补件内容</label>
				<input type="text" id="lv1SplmtAplRDsc" name="lv1SplmtAplRDsc"/>
				<input type="text" id="lvl2SplmtAplRDsc" name="lvl2SplmtAplRDsc"/>
				<input type="hidden" id="lv1SplmtAplRsnID" name="lv1SplmtAplRsnID"/>
				<input type="hidden" id="lvl2SplmtAplRsnID" name="lvl2SplmtAplRsnID"/>
				<span id="Lv1SplmtAplRsnIdBtn" ></span></li>
				
			</ul>
			
			<ul class="pjf_ul_three">
						<li>
							<label class="pjf_label">征信意见：</label>
							<textarea id="CrSurvyPosOpinDsc" name="CrSurvyPosOpinDsc"></textarea>
						</li>
					</ul>
		</div>
		<div id="LvlSplmtAplRsnID"></div>
		<div id="Lv1RjRsBtnWin"></div>
		</form>
	</div>
		</div>
	
	<!-- 人工征信页面到此为止 -->
	
	<!-- 操作按钮区 -->
	<div class="pjf_submit_con">
		<span id="btnSave"></span>
	</div>
</div>

</body>
</html>