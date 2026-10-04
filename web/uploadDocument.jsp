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

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Upload Document - StudentHub</title>
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

                <h2>Upload Document for <%= studentName %></h2>

                <% if ("1".equals(success)) { %>
                    <div class="alert alert-success">Document uploaded successfully.</div>
                <% } else if ("notype".equals(error)) { %>
                    <div class="alert alert-error">Please select a document type.</div>
                <% } else if ("nofile".equals(error)) { %>
                    <div class="alert alert-error">Please choose a PDF file.</div>
                <% } else if ("notpdf".equals(error)) { %>
                    <div class="alert alert-error">Only PDF files are allowed.</div>
                <% } else if ("toobig".equals(error)) { %>
                    <div class="alert alert-error">File is too large. Maximum size is 5 MB.</div>
                <% } %>

                <form action="UploadDocumentServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="studentId" value="<%= studentId %>">

                    <label>Document Type *</label>
                    <select name="docType" required>
                        <option value="">-- Select Document Type --</option>
                        <option value="10th Marksheet">10th Marksheet</option>
                        <option value="12th Marksheet">12th Marksheet</option>
                        <option value="Aadhaar Card">Aadhaar Card</option>
                        <option value="Other Certificate">Other Certificate</option>
                    </select>

                    <label>Choose PDF File *</label>
                    <input type="file" name="docFile" accept="application/pdf" required>

                    <div class="btn-row" style="margin-top: 10px;">
                        <button type="submit" class="btn btn-blue">Upload</button>
                        <a class="btn btn-cancel" href="viewDocuments.jsp?id=<%= studentId %>">Cancel</a>
                    </div>
                </form>

                <div style="margin-top: 20px;">
                    <a href="viewDocuments.jsp?id=<%= studentId %>">&larr; View uploaded documents</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>