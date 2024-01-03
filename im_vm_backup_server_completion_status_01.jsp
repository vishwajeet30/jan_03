<%@ page language = 'java' import = 'java.sql.*,java.io.*,java.text.*,javax.naming.*,javax.sql.*, org.apache.commons.fileupload.DiskFileUpload, org.apache.commons.fileupload.FileItem, java.lang.*, java.util.*,java.sql.*, javax.naming.*, javax.sql.*, java.io.FileOutputStream, java.io.IOException, com.lowagie.text.*, com.lowagie.text.pdf.*, com.lowagie.text.pdf.PdfWriter, java.awt.Color,java.lang.*,java.text.*, java.util.ArrayList, java.util.List, java.util.HashMap, java.util.LinkedHashMap, java.util.TreeMap, java.util.Map,java.util.Map,java.io.*, java.net.*'%>

<script>

function filtered_report()
{
	//alert(document.entryfrm.orange_filtered_report.value);
	document.entryfrm.action = "http://10.248.168.222:8888/Imm/server_logs/process_data_statistics/im_vm_backup_server_completion_status_01.jsp?text_filter=" + document.entryfrm.text_filter.value + "&icp_filter=" + document.entryfrm.icp_filter.value;
		//"&orange_filtered_report=" + document.entryfrm.orange_filtered_report.value ;
	document.entryfrm.submit();
	return true;			
}

function generate_report()
{
	document.entryfrm.action = "http://10.248.168.222:8888/Imm/server_logs/process_data_statistics/im_vm_backup_server_completion_status_01.jsp??text_filter=" + document.entryfrm.text_filter.value + "&icp_filter=" + document.entryfrm.icp_filter.value ;
	document.entryfrm.submit();
	return true;			
}

function reset_report()
{
	document.entryfrm.text_filter.value= "";
	document.entryfrm.action = "http://10.248.168.222:8888/Imm/server_logs/process_data_statistics/im_vm_backup_server_completion_status_01.jsp?text_filter=&icp_filter=&orange_filtered_report=No";
	document.entryfrm.submit();
	return true;			
}






function letternumber(e, str)
{
	var key;
	var keychar;
	if (window.event)
	   key = window.event.keyCode;
	else if (e)
	   key = e.which;
	else
	   return true;
	keychar = String.fromCharCode(key);
	keychar = keychar.toLowerCase();
	// control keys
	if ((key == null) || (key==0) || (key==8) || 
		(key==9) || (key==13) || (key==27) )
	   return true;
	// alphas and numbers
	else if ((str.indexOf(keychar) > -1))
	   return true;
	else
	   return false;
}

</script>

<%!
	BufferedReader executeCommand(String command) 
	{ 	
		StringBuffer output = new StringBuffer();
		Process p;
		try 
		{
			String cmd[] = {"/bin/sh", "-c", command};
			p = java.lang.Runtime.getRuntime().exec(cmd);
			
			//p = java.lang.Runtime.getRuntime().exec(command);		
			int value= p.waitFor();
			//System.out.println(command + "--" + value);
			if(p!=null && p.exitValue()!=0)System.out.println("Not Success " + p.exitValue());
			return new BufferedReader(new InputStreamReader(p.getInputStream()));		
		} 
		catch (Exception e) 
		{
			System.out.println(e.getMessage());
			e.printStackTrace();
		}	
		return null;
	}

	BufferedReader executeShellScript(String filePath) 
	{
		Process p;
		try 
		{
			p = java.lang.Runtime.getRuntime().exec("sh " + filePath);			
			try
			{
				int value= p.waitFor();
				if(p!=null && p.exitValue()!=0)
					System.out.println("Not Success " + p.exitValue());
			}
			catch(Exception e)
			{
				System.out.println(e.getMessage());
				e.printStackTrace();
			}
			return new BufferedReader(new InputStreamReader(p.getInputStream()));
			
		} 
		catch (Exception e) 
		{		
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		return null;
	}

	class ICP
	{
		String ip;
		String db_link;
		String icp_no;
		public ICP(String icp_no,  String db_link, String ip) {
			this.ip = ip;
			this.db_link = db_link;
			this.icp_no = icp_no;
		}
		public String get_db_link() {
			return db_link;
		}
		public String get_ip() {
			return ip;
		}
		public String get_icp_no() {
			return icp_no;
		}
	}

	int getConnectionFromIP (String ip) {
	int conn_stat = 0;
	try
		{
			
			InetAddress gk = InetAddress.getByName(ip);
			if(gk.isReachable(2000)){
				conn_stat = 1;
			} else {
				conn_stat = 0;
			}
			
		}
		catch (Exception e) 
		{
			System.out.println("\nError Exception: " + e.getMessage() + " -- MOIA-IND_UCFDetails -- " );
			
			conn_stat =  10;
		} finally {
			return conn_stat;
		}
		
		
	}
%>

<%

	
	/////////////////////////////////////////////////////////////////////////////////// Start: Junk Code /////////////////////////////////////////////////////////////////////////////////////////////////////
		
	//String show_all = request.getParameter("orange_filtered_report") == null ? "" : request.getParameter("orange_filtered_report").trim();
	//out.println(show_all);

/*	String text_filter = request.getParameter("text_filter") == null ? "0.0" : request.getParameter("text_filter").trim();
	if(text_filter.equals(""))	
		text_filter = "2.0";

	
	String use_percentage_filter_string = request.getParameter("use_percentage_filter") == null ? "" : request.getParameter("use_percentage_filter");
	if(use_percentage_filter_string.equals(""))	
		use_percentage_filter_string = "85";
*/
	String icp_filter = request.getParameter("icp_filter") == null ? "" : request.getParameter("icp_filter").toUpperCase().trim();
	if(icp_filter.equals(""))	
		icp_filter = "ALL";

	String orange_filtered_report = request.getParameter("orange_filtered_report") == null ? "" : request.getParameter("orange_filtered_report");
	//out.println(orange_filtered_report);
	//String orange_filtered_report = show_all;
	//if(orange_filtered_report.equals("on"))	
		//orange_filtered_report = "Yes";
	//out.println(orange_filtered_report);
	//int use_percentage_filter = Integer.parseInt(use_percentage_filter_string);
	
	//float text_filter_float = Float.parseFloat(text_filter);

	
	////////////////////////////////////////////////////////////////////////////////// End: Junk Code /////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////// Start : New Code for fetching process Data from File made from terminal of all the icps  ////////////////////////////////////////////////////

			String directory_prefix_name = "/usr/local/tomcat/webapps/Imm/server_logs/process_data_statistics/";

			String base_file_path1 =  directory_prefix_name + "imm_rsync_status_vm.txt";


			///////////////////////////////////////////////////////////////////////////////
				try {
					File file1 = new File(base_file_path1);
					FileReader fr1 = new FileReader(file1); //reads the file  
					BufferedReader br1 = new BufferedReader(fr1); //creates a buffering character input stream  

					String line1;
					String rename_file = "NO";
					while ((line1 = br1.readLine()) != null) {
						if (line1.contains("################ END TIME:")) {
							rename_file = "YES";
							break;
						}
					}
					fr1.close();

					if (rename_file.equals("YES")) {
						File f1 = new File(directory_prefix_name + "imm_rsync_status_vm_bk.txt");
						boolean b = f1.delete();
						f1 = new File(directory_prefix_name + "imm_rsync_status_vm.txt");

						File f2 = new File(directory_prefix_name + "imm_rsync_status_vm_bk.txt");
						b = f1.renameTo(f2);
					}
				} catch (Exception e) {
				}
				

			String base_file_path =  directory_prefix_name + "imm_rsync_status_vm_bk.txt";
			///////////////////////////////////////////////////////////////////////////////


			//String base_file_path =  directory_prefix_name + "ankit.txt";

			
			DateFormat vDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
			java.util.Date current_Server_Time = new java.util.Date();
			String report_start_time = vDateFormat.format(current_Server_Time);
			String report_end_time = vDateFormat.format(current_Server_Time);
			String report_end_time2 = vDateFormat.format(current_Server_Time);
			out.println("<center><font face='Verdana' color='Black' size='5'><b> VM Servers Backup Completion Status </b></font></center><BR>");

			BufferedReader br = null;
			BufferedReader br2 = null;
			BufferedReader br3 = null;



	//////////////////////////////////////////////////////////// End : New Code for fetching process Data from File made from terminal of all the icps  ////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////////////// New Code Starts ////////////////////////////////////////////////////////////////////////////////

	

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	

	///////////////////////////////////////////////////////////////////////////////////////////////		
	
	Map<String, String> proces_name_and_count_pair = new LinkedHashMap<String,String>();
	Map<String, String> special_server_name__ip_password_pair = new LinkedHashMap<String,String>();
	
	Map<String, String> all_icp_combiation_crontab_running_status = new LinkedHashMap<String,String>();
	Map<String, String> only_crontab_running_icp_combination = new LinkedHashMap<String,String>();
	Map<String, String> only = new LinkedHashMap<String,String>();
	
	
	////////////////////////// Start: Killing the Processes ////////////////////////////////////////
	
	///////////////////////// End: Killing the Processes /////////////////////////////////////////

	special_server_name__ip_password_pair.put("boi9","10.248.168.222#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cics1","172.16.1.51#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cics2","10.248.179.4#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cicsdr","10.52.160.68#####ivfrt@1234");
	special_server_name__ip_password_pair.put("dmrc205","10.248.168.205#####ivfrt@1234");
	special_server_name__ip_password_pair.put("dmrc66","10.248.168.219#####ivfrt@1234");
	special_server_name__ip_password_pair.put("dmrc67","10.248.168.220#####ivfrt@1234");
	special_server_name__ip_password_pair.put("ics-dr","10.52.160.79#####ivfrt@1234");
	special_server_name__ip_password_pair.put("icssp-201","10.248.168.201#####ivfrt@1234");
	special_server_name__ip_password_pair.put("sic1","10.248.179.6#####ivfrt@1234");
	special_server_name__ip_password_pair.put("sic2","10.248.179.7#####ivfrt@1234");
	special_server_name__ip_password_pair.put("trng","172.16.1.59#####ivfrt@1234");
	special_server_name__ip_password_pair.put("trng-new","172.16.1.74#####ivfrt@1234");
	special_server_name__ip_password_pair.put("tsc","10.248.168.211#####ivfrttsc@1234");
	special_server_name__ip_password_pair.put("imgsrv3","10.248.168.223#####img@1234");

	special_server_name__ip_password_pair.put("del1o","10.52.144.2#####ivfrt@1234");
	special_server_name__ip_password_pair.put("del2o","10.52.144.4#####ivfrt@1234");
	special_server_name__ip_password_pair.put("bom1o","10.52.137.6#####ivfrt@1234");
	special_server_name__ip_password_pair.put("bom2o","10.52.137.7#####ivfrt@1234");
	special_server_name__ip_password_pair.put("tvm1o","10.52.129.7#####ivfrt@1234");
	special_server_name__ip_password_pair.put("tvm2o","10.52.129.8#####ivfrt@1234");

	special_server_name__ip_password_pair.put("icssp","10.248.168.201#####ivfrt@1234");
	special_server_name__ip_password_pair.put("sicbk","10.248.179.27#####ivfrt@1234");
	special_server_name__ip_password_pair.put("apis_new","10.248.179.8#####ivfrt@1234");
	special_server_name__ip_password_pair.put("apis-dr","10.52.160.71#####ivfrt@1234");
	special_server_name__ip_password_pair.put("vtz-imgsrv2","10.52.129.71#####ivfrt@1234");
	special_server_name__ip_password_pair.put("vtz-imgsrv2","10.52.129.71#####ivfrt@1234");
	special_server_name__ip_password_pair.put("bom-imgsrv_new","10.52.137.8#####ivfrt@1234");
	special_server_name__ip_password_pair.put("del-imgsrv_old","10.52.144.10#####ivfrt@1234");
	special_server_name__ip_password_pair.put("har-imgsrv_new","10.52.143.7#####ivfrt@1234");
	special_server_name__ip_password_pair.put("try-imgsrv_new","10.52.145.71#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cha-imgsrv_new1","10.52.133.216#####ivfrt@1234");
	special_server_name__ip_password_pair.put("sur-imgsrv1","10.52.146.132#####ivfrt@1234");
	special_server_name__ip_password_pair.put("sur-imgsrv2","10.52.146.133#####ivfrt@1234");
	special_server_name__ip_password_pair.put("del-imgsrv_new","10.52.144.6#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cal-imgsrv_new","10.52.141.7#####ivfrt@1234");
	special_server_name__ip_password_pair.put("mng_imgsrv_2","10.52.146.2#####ivfrt@1234");
	special_server_name__ip_password_pair.put("pne-imgsrv_9","10.52.132.9#####ivfrt@1234");
	special_server_name__ip_password_pair.put("goa_imgsrv_2","10.52.138.6#####ivfrt@1234");
	special_server_name__ip_password_pair.put("mng_imgsrv_2","10.52.146.2#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cics-imgsrv","10.52.133.10#####ivfrt@1234");
	special_server_name__ip_password_pair.put("cics-imgsrv1","10.52.160.69#####ivfrt@1234");
	special_server_name__ip_password_pair.put("srv1","10.248.168.222#####ivfrt@1234");
	special_server_name__ip_password_pair.put("BOI1.NIC","10.52.133.1#####ivfrt@1234");
	special_server_name__ip_password_pair.put("CICS-SP","10.248.179.4#####ivfrt@1234");


	


try 
	{					
			br = new BufferedReader(new FileReader(base_file_path));
			String line = "";


			
			boolean new_icp_found = false;
			String icp_name_heading = "";
			String user_name = "";
			String password = "";
			int icp_count_serial_no = 0;

			//////////////////////////////////////////////////////////////////////////////////////////////////////
			
			int starting_count = 0;

			

			
			ArrayList<String> server_1_missing = new ArrayList<String>();
			ArrayList<String> server_2_missing = new ArrayList<String>();
			ArrayList<String> server_img_missing = new ArrayList<String>();
			
			ArrayList<String> server_1_different = new ArrayList<String>();
			ArrayList<String> server_2_different = new ArrayList<String>();
			ArrayList<String> server_img_different = new ArrayList<String>();

			ArrayList<String> server_1_directories = new ArrayList<String>();
			ArrayList<String> server_2_directories = new ArrayList<String>();
			ArrayList<String> server_img_directories = new ArrayList<String>();
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////

			//////////////////////// Start: The main table starts from here. ////////////////////////////////////////////////////
			
		DateFormat vDateFormat_new = new SimpleDateFormat("yyyyMMdd");
			//java.util.Date current_Server_Time = new java.util.Date();
			int log_file_date_diff = vDateFormat_new.parse(vDateFormat_new.format(current_Server_Time)).compareTo(vDateFormat_new.parse(vDateFormat_new.format(new File(base_file_path).lastModified())));	
				%>
					
						<table class="tableDesign" style="margin:auto;"> 


			<tr style="font-family: Verdana; font-size: 8pt; color:#54B2A9;font-weight: normal">
				<td colspan="3" style="border-color: #055ca5;"><center>########### Start Time <%=report_start_time %> ###########</center></td>
			</tr>
			<tr style="background-color:#87CEEB;font-weight:bold;color: white;">
			<%	if(new File(base_file_path).exists())
				{
					if(log_file_date_diff > 0)
					{
				%>
					<td align="left" colspan="3" background="Blink.gif" style="border-color: #055ca5;"><font style="font-family: Verdana; font-size: 10pt; text-decoration : none;">Last Modified : <%=vDateFormat.format(new File(base_file_path).lastModified())%></font></td>
				<%
					}
				else
					{
				%>
					<td align="left" colspan="3" style="background-color:#3397eb;border-color: #055ca5;"><font style="font-family: Verdana; font-size: 10pt; text-decoration : none;">Last Modified : <%=vDateFormat.format(new File(base_file_path).lastModified())%></font></td>
				<%
					}
				}
			%>
			</tr>
		
			<form name="entryfrm" method="post">
				
					<tr bgcolor="lightgray">
						<td colspan="3">
						<font face=verdana color="#996666" size="2">
						&nbsp;<B>Filter&nbsp;on&nbsp;ICP</B>&nbsp;</font>
						<input type="text" style="font-family:Verdana;font-weight:bold; text-transform:uppercase;"  size="3" maxlength="5" onKeyDown="if(event.keyCode==13) mainFuncMrpWise('0'); if (event.keyCode==8) event.keyCode=37+46;" onKeyPress="return letternumber(event, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyxz')" name="icp_filter" id="icp_filter" value="<%=request.getParameter("icp_filter").trim()%>" size="25" maxlength="25">


						<input name="text_filter" id="text_filter" type="hidden">

						</input> &nbsp;<input type="button" class="Button" value="Generate" onclick="generate_report();" style=" font-family: Verdana; font-size: 9pt; color:#000000; font-weight: bold"></input>
						&nbsp;&nbsp;<input type="button" class="Button" value="Reset" onclick="reset_report();" style=" font-family: Verdana; font-size: 9pt; color:#000000; font-weight: bold"></input>
						
						
						<font face=verdana color="#996666" size="1">Show&nbsp;all&nbsp;ICP&nbsp;details&nbsp;</font>
				
						<input onclick="filtered_report();" type="checkbox" <%=!(orange_filtered_report.trim().equals(""))?"checked":""%> id="orange_filtered_report" name="orange_filtered_report"></input>
						</td>	
					</tr>
				
			</form>


		<tr height="40"><td colspan="3"></td></tr>
						
							<tr style="background-color:#E6E6EA;font-weight:bold">
								<td style="text-align:left; background-color: #1087eb; color: white;border-color: #055ca5;font-size:14px;font-family:verdana;">S.No.</td>				
								<td style="text-align:left; background-color: #1087eb; color: white;border-color: #055ca5;font-size:14px;font-family:verdana;">ICP</td>				
								<td style="text-align:left; background-color: #1087eb; color: white;border-color: #055ca5;font-size:14px;font-family:verdana;">VM&nbsp;Servers&nbsp;Backup&nbsp;Completion&nbsp;Status</td>				
							</tr>
					<%


			//////////////////////// End: The main table starts from here. /////////////////////////////////////////////////////	

		

			boolean startPrinting = false;

			while ((line = br.readLine())!= null) 
			{	

				if(line.trim().equals("") || line.trim().equals("***** rsync Status of Server-1 to VM Servers *****") || line.trim().equals("***** rsync Status of VM Servers to Server-1 *****"))
					continue;
				
				if(line.contains("################ START TIME"))
				{
					startPrinting = true;
					continue;
				}

				if(line.contains("################ END TIME"))
				{
					break;
				}
				
				if(startPrinting == true && line.contains("----"))
				{
					try{
						//String icp_name = line;
						String icp_name = line.split("\\.")[1].split("-")[0].replace("1_VM","").replace("1_vm","").replace("1","");
						String print_status = "";
						
						if(line.contains("server backup completed on"))
							print_status = "Completed";
						else
							print_status = "Not Completed";

						if(!orange_filtered_report.equals(""))
						{

							%>
								<tr>
									<td align="left" style="border-color: #055ca5;font-family:verdana;font-size:12px;"><%=++icp_count_serial_no%></td>
									<td align="left"style="border-color: #055ca5;font-family:verdana;font-size:12px;"><%=icp_name%></td>
<%							if(print_status == "Completed")
								{
%>									<td align="left"style="border-color: #055ca5;font-family:verdana;font-size:12px;"><%=print_status%></td>
<%								}else
									{
%>										<td align="left" style="background-color:red;border-color:#055ca5;font-family:verdana;font-size:12px;font-weight:bold;color:white"><%=print_status%></td>
<%									}
%>								</tr>	
<%
						}
						else
						{	
							if(!print_status.equals("Completed"))
							{
								%>
									<tr>
										<td align="left"style="border-color: #055ca5;font-family:verdana;font-size:12px"><%=++icp_count_serial_no%></td>
										<td align="left"style="border-color: #055ca5;font-family:verdana;font-size:12px"><%=icp_name%></td>
										<td align="left" style="background-color:red;border-color: #055ca5;font-family:verdana;font-weight:bold;font-size:12px; color:white;"><%=print_status%></td>
									</tr>	
								<%
							}
					}
					}
					catch(Exception e)
					{/*out.println(line);*/}
				}

				
				
				
			}

			
			
		
			
		if(br!=null)	
			br.close();
			
		
	////////////////////////////////////////////   New Code Ends  ///////////////////////////////
	}
	catch (IOException e) 
	{
		System.err.println(e);
	}
	
%>
<tr style="background-color:#87CEEB;font-weight:bold;color: white;">
		<td colspan="3" align="center" style="font-family:verdana; font-size:12px;background-color:#3397eb;border-color: #055ca5;">End of Report</td>
	</tr>


	<%
			java.util.Date end_time = new java.util.Date();
			report_end_time = vDateFormat.format(end_time);
					
			long time_diff = (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(report_end_time).getTime() - new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(report_start_time).getTime())/1000;
			long hours = time_diff/3600;
			long minits = (time_diff%3600)/60;
			long seconds = time_diff%60;
			String str_time_difference = hours+" hr "+minits+" min "+seconds+" sec";
		%>
		 
			<tr style="font-family: Verdana; font-size: 8pt; color:#54B2A9;">
				<td colspan="3" style="font-family:verdana;border-color: #055ca5;"><center>## End Time <%=report_end_time %> Time Taken : <%=str_time_difference%> ##</center></td>
			</tr>
			</table>

<%
	

%>

<html><head><title>Image Search from Image Server (Junk Images)</title>
<style type="text/css">
	
.tableDesign {
border-collapse: separate;
border-spacing: 0;	
}
.tableDesign tr th, .tableDesign tr td {
border-right: 1px solid #bbb;
border-bottom: 1px solid #bbb;
padding: 5px;
}

.tableDesign tr th:first-child, .tableDesign tr td:first-child {
border-left: 1px solid #bbb;
}

.tableDesign tr th {
background: #eee;
border-top: 1px solid #bbb;
text-align: left;
}

/* top-left border-radius */
.tableDesign tr:first-child th:first-child {
border-top-left-radius: 10px;
}

/* top-right border-radius */
.tableDesign tr:first-child th:last-child {
border-top-right-radius: 10px;
}

/* bottom-left border-radius */
.tableDesign tr:last-child td:first-child {
border-bottom-left-radius: 10px;
}

/* bottom-right border-radius */
.tableDesign tr:last-child td:last-child {
border-bottom-right-radius: 10px;
}

.right{
text-align :right;
}

</style>

	<script>

		function displayimage(str)
		{
			document.images.imagepath.value = str; //alert(imageName);
			document.images.target = "rightside"
			document.images.action = "im_imgsrv_imgCorrection04.jsp";
			document.images.submit();

			document.images.target = "search"
			document.images.action = "im_imgsrv_imgCorrection06.jsp";
			document.images.submit();
		}

		var radioId;
		function hide(radioId)
		{
			if(radioId != 0)
			{
				d = document.getElementById("row"+radioId);
				d.style.backgroundColor ='#FFBFDF';
				d.style.color ='white';
				d.style.fontWeight ='normal';
				d.style.fontSize ='10pt';
			}
		   var table = document.getElementById('locate');   
		   var rows = table.getElementsByTagName("tr");   
		   for(i=0;i<rows.length;i++)
			{
			   if(("row"+radioId) != rows[i].id)
				{
				   rows[i].style.background = '#eeeecc';
				   rows[i].style.fontWeight = 'normal';
				   rows[i].style.fontSize = '10pt';
				   rows[i].style.color = 'brown';
				}
			}
		}
	</script>
</head>
<body>
<form name="images" method="post">
<input type='hidden' name='imagepath'>
</form>


</body></html>