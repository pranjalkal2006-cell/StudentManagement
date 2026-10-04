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
    <title>Clubs - StudentHub</title>
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
            <h2>Add a Club</h2>
            <% if ("1".equals(success)) { %>
                <div class="alert alert-success">Club added successfully.</div>
            <% } else if ("empty".equals(error)) { %>
                <div class="alert alert-error">Club name cannot be empty.</div>
            <% } else if ("duplicate".equals(error)) { %>
                <div class="alert alert-error">This club already exists.</div>
            <% } %>
            <form action="AddClubServlet" method="post">
                <label>Club Name *</label>
                <input type="text" name="clubName" placeholder="e.g. Robotics Club" required>
                <button type="submit" class="btn btn-blue">Add Club</button>
            </form>
        </div>

        <div class="panel">
            <h2>Existing Clubs</h2>
            <table>
                <tr><th>Club Name</th><th>Members</th></tr>
                <%
                    try (Connection con = DBConnection.getConnection();
                         Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery(
                             "SELECT cl.club_name, COUNT(sc.student_id) AS total " +
                             "FROM clubs cl LEFT JOIN student_clubs sc ON cl.club_id = sc.club_id " +
                             "GROUP BY cl.club_name ORDER BY cl.club_name")) {
                        while (rs.next()) {
                %>
                    <tr><td><%= rs.getString("club_name") %></td><td><%= rs.getInt("total") %></td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr><td colspan="2" style="color:#d13438;">Error: <%= e.getMessage() %></td></tr>
                <% } %>
            </table>
        </div>
    </div>
</body>
</html>