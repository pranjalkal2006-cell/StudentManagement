<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Courses - StudentHub</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body>

    <div class="navbar">
        <span class="brand">StudentHub</span>
        <span>
            <a href="dashboard.jsp">Dashboard</a>
            <a href="addStudent.jsp">Add Student</a>
            <a href="viewStudents.jsp">Students</a>
            <a href="manageCourses.jsp">Courses</a>
            <a href="LogoutServlet">Logout (<%= session.getAttribute("admin") %>)</a>
        </span>
    </div>

    <div class="container">
        <div class="panel">
            <h2>Add a Course</h2>

            <% if ("1".equals(success)) { %>
                <div class="alert alert-success">Course added successfully.</div>
            <% } else if ("empty".equals(error)) { %>
                <div class="alert alert-error">Course name cannot be empty.</div>
            <% } else if ("duplicate".equals(error)) { %>
                <div class="alert alert-error">This course already exists.</div>
            <% } %>

            <form action="AddCourseServlet" method="post">
                <label>Course Name *</label>
                <input type="text" name="courseName" placeholder="e.g. B.Tech ECE" required>
                <button type="submit" class="btn btn-blue">Add Course</button>
            </form>
        </div>

        <div class="panel">
            <h2>Existing Courses</h2>
            <table>
                <tr><th>Course Name</th></tr>
                <%
                    try (Connection con = DBConnection.getConnection();
                         Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery(
                             "SELECT course_name FROM courses ORDER BY course_name")) {
                        while (rs.next()) {
                %>
                    <tr><td><%= rs.getString("course_name") %></td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr><td style="color:#d13438;">Error: <%= e.getMessage() %></td></tr>
                <% } %>
            </table>
        </div>
    </div>

</body>
</html>