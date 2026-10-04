<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String error = request.getParameter("error");
    int id = 0;
    try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { }

    String rollNo = "", name = "", email = "", phone = "";
    int courseId = 0, year = 0;
    boolean found = false;
    Set<Integer> studentClubIds = new HashSet<Integer>();

    if (id > 0) {
        try (Connection con = DBConnection.getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM students WHERE student_id = ?");
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                found = true;
                rollNo = rs.getString("roll_no");
                name = rs.getString("name");
                email = rs.getString("email") == null ? "" : rs.getString("email");
                phone = rs.getString("phone") == null ? "" : rs.getString("phone");
                courseId = rs.getInt("course_id");
                year = rs.getInt("year");
            }

            if (found) {
                PreparedStatement cps = con.prepareStatement(
                    "SELECT club_id FROM student_clubs WHERE student_id = ?");
                cps.setInt(1, id);
                ResultSet crs = cps.executeQuery();
                while (crs.next()) {
                    studentClubIds.add(crs.getInt("club_id"));
                }
            }
        } catch (Exception e) {
            error = "db";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Student - StudentHub</title>
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
            <h2>Edit Student</h2>

            <% if (!found) { %>
                <div class="alert alert-error">Student record not found.</div>
                <a class="btn" href="viewStudents.jsp">Back to Students</a>
            <% } else { %>

                <% if ("required".equals(error)) { %>
                    <div class="alert alert-error">Please fill all required fields.</div>
                <% } else if ("phone".equals(error)) { %>
                    <div class="alert alert-error">Phone number must be exactly 10 digits.</div>
                <% } %>

                <form action="EditStudentServlet" method="post">
                    <input type="hidden" name="id" value="<%= id %>">

                    <label>Roll No *</label>
                    <input type="text" name="rollNo" value="<%= rollNo %>" required>

                    <label>Full Name *</label>
                    <input type="text" name="name" value="<%= name %>" required>

                    <label>Email</label>
                    <input type="email" name="email" value="<%= email %>">

                    <label>Phone (10 digits)</label>
                    <input type="text" name="phone" value="<%= phone %>"
                           pattern="\d{10}" title="Enter exactly 10 digits" maxlength="10">

                    <label>Course *</label>
                    <select name="courseId" required>
                        <%
                            try (Connection con = DBConnection.getConnection();
                                 Statement st = con.createStatement();
                                 ResultSet rs = st.executeQuery(
                                     "SELECT course_id, course_name FROM courses ORDER BY course_name")) {
                                while (rs.next()) {
                                    int cid = rs.getInt("course_id");
                                    String sel = (cid == courseId) ? "selected" : "";
                        %>
                            <option value="<%= cid %>" <%= sel %>><%= rs.getString("course_name") %></option>
                        <%
                                }
                            } catch (Exception e) { %>
                                <option value="">Error loading courses</option>
                        <% } %>
                    </select>

                    <label>Year *</label>
                    <select name="year" required>
                        <% for (int y = 1; y <= 4; y++) {
                               String sel = (y == year) ? "selected" : ""; %>
                            <option value="<%= y %>" <%= sel %>><%= y %> Year</option>
                        <% } %>
                    </select>

                    <label>Clubs</label>
                    <div style="margin-bottom: 14px;">
                        <%
                            try (Connection con = DBConnection.getConnection();
                                 Statement st = con.createStatement();
                                 ResultSet rs = st.executeQuery(
                                     "SELECT club_id, club_name FROM clubs ORDER BY club_name")) {
                                while (rs.next()) {
                                    int cid = rs.getInt("club_id");
                                    String checked = studentClubIds.contains(cid) ? "checked" : "";
                        %>
                            <label style="display:inline-flex; align-items:center; gap:6px; font-weight:400; margin-right:16px;">
                                <input type="checkbox" name="clubIds" value="<%= cid %>" style="width:auto; margin:0;" <%= checked %>>
                                <%= rs.getString("club_name") %>
                            </label>
                        <%
                                }
                            } catch (Exception e) { %>
                                <span style="color:#d13438;">Could not load clubs</span>
                        <% } %>
                    </div>

                    <div class="btn-row" style="margin-top: 10px;">
                        <button type="submit" class="btn btn-blue">Update Student</button>
                        <a class="btn btn-cancel" href="viewStudents.jsp">Cancel</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

</body>
</html>