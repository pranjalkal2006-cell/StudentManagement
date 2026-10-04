<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    int studentId = (Integer) session.getAttribute("studentId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Documents - StudentHub</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body>
    <div class="navbar">
        <span class="brand">StudentHub</span>
        <span>
            <a href="studentDashboard.jsp">My Profile</a>
            <a href="studentDocuments.jsp">My Documents</a>
            <a href="studentFees.jsp">My Fees</a>
            <a href="StudentLogoutServlet">Logout</a>
        </span>
    </div>

    <div class="container">
        <div class="panel">
            <h2>My Documents</h2>

            <table>
                <tr><th>Document Type</th><th>File Name</th><th>Uploaded On</th><th>Action</th></tr>
                <%
                    try (Connection con = DBConnection.getConnection();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT * FROM student_documents WHERE student_id = ? ORDER BY uploaded_at DESC")) {
                        ps.setInt(1, studentId);
                        ResultSet rs = ps.executeQuery();
                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                %>
                    <tr>
                        <td><%= rs.getString("doc_type") %></td>
                        <td><%= rs.getString("file_name") %></td>
                        <td><%= rs.getTimestamp("uploaded_at") %></td>
                        <td><a href="<%= rs.getString("file_path") %>" target="_blank">View/Download</a></td>
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="4" style="text-align:center; color:#6b7280;">No documents uploaded yet.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr><td colspan="4" style="color:#d13438;">Error: <%= e.getMessage() %></td></tr>
                <% } %>
            </table>
        </div>
    </div>
</body>
</html>