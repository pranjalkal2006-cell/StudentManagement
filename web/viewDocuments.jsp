<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int studentId = 0;
    try { studentId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { }

    String studentName = null;
    if (studentId > 0) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT name FROM students WHERE student_id = ?")) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) studentName = rs.getString("name");
        } catch (Exception e) { }
    }

    String uploaded = request.getParameter("uploaded");
    String deleted = request.getParameter("deleted");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Documents - StudentHub</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body>
    <div class="navbar">
        <span class="brand">StudentHub</span>
        <span>
            <a href="dashboard.jsp">Dashboard</a>
            <a href="addStudent.jsp">Add Student</a>
            <a href="manageCourses.jsp">Courses</a>
            <a href="manageClubs.jsp">Clubs</a>
            <a href="viewStudents.jsp">Students</a>
            <a href="LogoutServlet">Logout (<%= session.getAttribute("admin") %>)</a>
        </span>
    </div>

    <div class="container">
        <div class="panel">

            <% if (studentName == null) { %>
                <div class="alert alert-error">Student not found.</div>
                <a class="btn" href="viewStudents.jsp">Back to Students</a>
            <% } else { %>

                <h2>Documents for <%= studentName %></h2>

                <% if ("1".equals(uploaded)) { %>
                    <div class="alert alert-success">Document uploaded successfully.</div>
                <% } else if ("1".equals(deleted)) { %>
                    <div class="alert alert-success">Document deleted successfully.</div>
                <% } %>

                <a class="btn" href="uploadDocument.jsp?id=<%= studentId %>" style="margin-bottom: 16px; display: inline-block;">
                    + Upload New Document
                </a>

                <table>
                    <tr><th>Document Type</th><th>File Name</th><th>Uploaded On</th><th>Actions</th></tr>
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
                            <td>
                                <a href="<%= rs.getString("file_path") %>" target="_blank">View/Download</a>
                                &nbsp;|&nbsp;
                                <a href="DeleteDocumentServlet?docId=<%= rs.getInt("doc_id") %>&studentId=<%= studentId %>"
                                   style="color:#d13438;"
                                   onclick="return confirm('Delete this document?');">Delete</a>
                            </td>
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

                <div style="margin-top: 20px;">
                    <a href="viewStudents.jsp">&larr; Back to Students</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>