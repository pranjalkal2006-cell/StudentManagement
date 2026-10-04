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
    <title>Add Student - StudentHub</title>
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
            <h2>Add Student</h2>

            <% if ("1".equals(success)) { %>
                <div class="alert alert-success">Student added successfully.</div>
            <% } else if ("required".equals(error)) { %>
                <div class="alert alert-error">Please fill all required fields.</div>
            <% } else if ("phone".equals(error)) { %>
                <div class="alert alert-error">Phone number must be exactly 10 digits.</div>
            <% } else if ("duplicate".equals(error)) { %>
                <div class="alert alert-error">This roll number already exists.</div>
            <% } %>

            <form action="AddStudentServlet" method="post">

                <label>Roll No *</label>
                <input type="text" name="rollNo" required>

                <label>Full Name *</label>
                <input type="text" name="name" required>

                <label>Email</label>
                <input type="email" name="email">

                <label>Phone (10 digits)</label>
                <input type="text" name="phone" pattern="\d{10}"
                       title="Enter exactly 10 digits" maxlength="10">

                <label>Course *</label>
                <select name="courseId" required>
                    <option value="">-- Select Course --</option>
                    <%
                        try (Connection con = DBConnection.getConnection();
                             Statement st = con.createStatement();
                             ResultSet rs = st.executeQuery(
                                 "SELECT course_id, course_name FROM courses ORDER BY course_name")) {
                            while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("course_id") %>">
                            <%= rs.getString("course_name") %>
                        </option>
                    <%
                            }
                        } catch (Exception e) { %>
                            <option value="">Error loading courses</option>
                    <% } %>
                </select>

                <label>Year *</label>
                <select name="year" required>
                    <option value="">-- Select Year --</option>
                    <option value="1">1st Year</option>
                    <option value="2">2nd Year</option>
                    <option value="3">3rd Year</option>
                    <option value="4">4th Year</option>
                </select>

                <label>Clubs</label>
                <div style="margin-bottom: 14px;">
                    <%
                        try (Connection con = DBConnection.getConnection();
                             Statement st = con.createStatement();
                             ResultSet rs = st.executeQuery(
                                 "SELECT club_id, club_name FROM clubs ORDER BY club_name")) {
                            while (rs.next()) {
                    %>
                        <label style="display:inline-flex; align-items:center; gap:6px; font-weight:400; margin-right:16px;">
                            <input type="checkbox" name="clubIds" value="<%= rs.getInt("club_id") %>" style="width:auto; margin:0;">
                            <%= rs.getString("club_name") %>
                        </label>
                    <%
                            }
                        } catch (Exception e) { %>
                            <span style="color:#d13438;">Could not load clubs</span>
                    <% } %>
                </div>

                <div class="btn-row" style="margin-top: 10px;">
                    <button type="submit" class="btn btn-blue">Save Student</button>
                    <a class="btn btn-cancel" href="dashboard.jsp">Cancel</a>
                </div>
            </form>
        </div>
    </div>

</body>
</html>