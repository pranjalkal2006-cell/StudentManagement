<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String q = request.getParameter("q");
    if (q == null) q = "";
    String deleted = request.getParameter("deleted");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Students - StudentHub</title>
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
            <h2>Students</h2>

            <% if ("1".equals(deleted)) { %>
                <div class="alert alert-success">Student deleted successfully.</div>
            <% } %>

            <form class="toolbar" method="get" action="viewStudents.jsp">
                <input type="text" name="q" placeholder="Search by name or roll no..."
                       value="<%= q.replace("\"", "&quot;") %>">
                <button type="submit" class="btn">Search</button>
                <a class="btn btn-secondary" href="viewStudents.jsp">Clear</a>
            </form>

            <table>
                <tr>
                    <th>Roll No</th><th>Name</th><th>Course</th>
                    <th>Year</th><th>Clubs</th><th>Phone</th><th>Actions</th>
                </tr>
                <%
                    try (Connection con = DBConnection.getConnection();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT s.student_id, s.roll_no, s.name, s.phone, s.year, c.course_name, " +
                             "GROUP_CONCAT(cl.club_name SEPARATOR ', ') AS clubs " +
                             "FROM students s JOIN courses c ON s.course_id = c.course_id " +
                             "LEFT JOIN student_clubs sc ON s.student_id = sc.student_id " +
                             "LEFT JOIN clubs cl ON sc.club_id = cl.club_id " +
                             "WHERE s.name LIKE ? OR s.roll_no LIKE ? " +
                             "GROUP BY s.student_id " +
                             "ORDER BY s.student_id DESC")) {

                        ps.setString(1, "%" + q + "%");
                        ps.setString(2, "%" + q + "%");
                        ResultSet rs = ps.executeQuery();
                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                %>
                    <tr>
                        <td><%= rs.getString("roll_no") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= rs.getInt("year") %></td>
                        <td><%= rs.getString("clubs") == null ? "-" : rs.getString("clubs") %></td>
                        <td><%= rs.getString("phone") == null ? "-" : rs.getString("phone") %></td>
                        <td>
                            <a href="editStudent.jsp?id=<%= rs.getInt("student_id") %>">Edit</a>
                                &nbsp;|&nbsp;
                            <a href="viewDocuments.jsp?id=<%= rs.getInt("student_id") %>">Documents</a>
                                &nbsp;|&nbsp;
                            <a href="viewFees.jsp?id=<%= rs.getInt("student_id") %>">Fees</a>
                                &nbsp;|&nbsp;
                            <a href="DeleteStudentServlet?id=<%= rs.getInt("student_id") %>"
                               style="color:#d13438;"
                               onclick="return confirm('Delete this student record?');">Delete</a>
                        </td>
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="7" style="text-align:center; color:#6b7280;">No students found.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr><td colspan="7" style="color:#d13438;">Error: <%= e.getMessage() %></td></tr>
                <% } %>
            </table>
        </div>
    </div>

</body>
</html>