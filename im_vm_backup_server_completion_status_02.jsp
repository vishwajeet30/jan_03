<%@ page language = 'java' import = 'java.sql.*,java.io.*,java.text.*,javax.naming.*,javax.sql.*, org.apache.commons.fileupload.DiskFileUpload, org.apache.commons.fileupload.FileItem, java.lang.*, java.util.*,java.sql.*, javax.naming.*, javax.sql.*, java.io.FileOutputStream, java.io.IOException, com.lowagie.text.*, com.lowagie.text.pdf.*, com.lowagie.text.pdf.PdfWriter, java.awt.Color,java.lang.*,java.text.*, java.util.ArrayList, java.util.List, java.util.HashMap, java.util.LinkedHashMap, java.util.TreeMap, java.util.Map,java.util.Map,java.io.*, java.net.*'%>

<head>
<script>
//////////////////////////////////////////
function resize_frame() 
{
	old_frame_size=parent.document.getElementById('frame_reports').rows;
	parent.document.getElementById('frame_reports').rows = '150,*';
}
function reset_frame() 
{
	parent.document.getElementById('frame_reports').rows = '85%,*';
}
//////////////////////////////////////////
</script>
</head>
<body bgcolor="#C2F9BB" onmouseover="resize_frame()" onmouseout="reset_frame()">
<form name="images" method="post">
<input type='hidden' name='imagepath'>
</form>

	<table align="left" width="100%" cellspacing="2" cellpadding="2" border="0" style="background-color:#C2F9BB;font-family:verdana;font-size:12pt">
			<tr style="font-family: Verdana; font-size: 10pt; color:darkgreen; font-weight: italic;  align: left">
				<td>This data is coming from (10.248.168.222) server using [/home/master/zia/script/servers_crond_status.sh] [/Imm/server_logs/process_data_statistics/im_crontab_running_status.jsp] files<br><br></td>
			</tr>
			<tr style="font-family: Verdana; font-size: 10pt; color:darkgreen; font-weight: italic; align: left">
				<td>Crontab Entry on (10.248.168.222) --> 0 08,09,10,11,12,13,14,15,16,17,18 * * 1-5 root flock -n /var/run/servers_crond_status.lock /home/master/zia/script/servers_crond_status.sh > /usr/local/tomcat/webapps/Imm/server_logs/process_data_statistics/servers_crontab_status.txt<br><br></td>
			</tr>
	<%
		File file = new File("/usr/local/tomcat/webapps/Imm/server_logs/process_data_statistics/imm_rsync_status_vm_bk.txt"); //creates a new file instance  
		FileReader fr = new FileReader(file); //reads the file  
		 BufferedReader br = new BufferedReader(fr); //creates a buffering character input stream  
		// StringBuffer sb=new StringBuffer();    //constructs a string buffer with no characters  
		String line;
	%>
	       
	         <tr style="border-collapse: collapse;background-color:#C2F9BB;font-family:courier;font-size:8pt;text-align:left;left:500px;color:blue;"><td align="left">
			 <!--<pre>
	         <% while((line=br.readLine())!=null)  
	          { 
	          if(line.trim().length() > 0)
	          %>
	         <%=line%>
	         <% }  
	          fr.close();  %>
	          </pre>-->
			  <iframe src="imm_rsync_status_vm_bk.txt" width="100%" height="600" style="border:none;"></iframe>
			  </td></tr>
	         </table>
</body></html>