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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add Fee - StudentHub</title>
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

                <h2>Add Fee for <%= studentName %></h2>

                <% if ("required".equals(error)) { %>
                    <div class="alert alert-error">Please fill all fields correctly.</div>
                <% } %>

                <form action="AddFeeServlet" method="post">
                    <input type="hidden" name="studentId" value="<%= studentId %>">

                    <label>Fee Type *</label>
                    <select name="feeType" required>
                        <option value="">-- Select Fee Type --</option>
                        <option value="Tuition Fee">Tuition Fee</option>
                        <option value="Exam Fee">Exam Fee</option>
                        <option value="Hostel Fee">Hostel Fee</option>
                        <option value="Library Fee">Library Fee</option>
                        <option value="Other">Other</option>
                    </select>

                    <label>Amount (INR) *</label>
                    <input type="number" name="amount" min="1" step="0.01" required>

                    <label>Due Date *</label>
                    <input type="date" name="dueDate" required>

                    <div class="btn-row" style="margin-top: 10px;">
                        <button type="submit" class="btn btn-blue">Add Fee</button>
                        <a class="btn btn-cancel" href="viewFees.jsp?id=<%= studentId %>">Cancel</a>
                    </div>
                </form>

                <div style="margin-top: 20px;">
                    <a href="viewFees.jsp?id=<%= studentId %>">&larr; View fee records</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>