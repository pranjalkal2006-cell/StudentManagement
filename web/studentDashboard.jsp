<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    int studentId = (Integer) session.getAttribute("studentId");

    String rollNo = "", name = "", email = "", phone = "", courseName = "";
    int year = 0;

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT s.roll_no, s.name, s.email, s.phone, s.year, c.course_name " +
             "FROM students s JOIN courses c ON s.course_id = c.course_id " +
             "WHERE s.student_id = ?")) {
        ps.setInt(1, studentId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            rollNo = rs.getString("roll_no");
            name = rs.getString("name");
            email = rs.getString("email") == null ? "-" : rs.getString("email");
            phone = rs.getString("phone") == null ? "-" : rs.getString("phone");
            year = rs.getInt("year");
            courseName = rs.getString("course_name");
        }
    } catch (Exception e) { }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Profile - StudentHub</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body>
    <div class="navbar">
        <span class="brand">StudentHub</span>
        <span>
            <a href="studentDashboard.jsp">My Profile</a>
            <a href="studentDocuments.jsp">My Documents</a>
            <a href="studentFees.jsp">My Fees</a>
            <a href="StudentLogoutServlet">Logout (<%= name %>)</a>
        </span>
    </div>

    <div class="container">
        <div class="panel">
            <h2>Welcome, <%= name %></h2>
            <p>Here is your student profile.</p>
        </div>

        <div class="panel">
            <table>
                <tr><th>Field</th><th>Details</th></tr>
                <tr><td>Roll No</td><td><%= rollNo %></td></tr>
                <tr><td>Name</td><td><%= name %></td></tr>
                <tr><td>Course</td><td><%= courseName %></td></tr>
                <tr><td>Year</td><td><%= year %></td></tr>
                <tr><td>Email</td><td><%= email %></td></tr>
                <tr><td>Phone</td><td><%= phone %></td></tr>
            </table>
        </div>
    </div>
</body>
</html>