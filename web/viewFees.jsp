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

    String added = request.getParameter("added");
    String paid = request.getParameter("paid");

    double totalDue = 0, totalPaid = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Fees - StudentHub</title>
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

                <h2>Fee Records for <%= studentName %></h2>

                <% if ("1".equals(added)) { %>
                    <div class="alert alert-success">Fee record added successfully.</div>
                <% } else if ("1".equals(paid)) { %>
                    <div class="alert alert-success">Fee marked as paid.</div>
                <% } %>

                <a class="btn" href="addFee.jsp?id=<%= studentId %>" style="margin-bottom: 16px; display: inline-block;">
                    + Add Fee Record
                </a>

                <table>
                    <tr><th>Fee Type</th><th>Amount</th><th>Due Date</th><th>Status</th><th>Paid Date</th><th>Actions</th></tr>
                    <%
                        try (Connection con = DBConnection.getConnection();
                             PreparedStatement ps = con.prepareStatement(
                                 "SELECT * FROM student_fees WHERE student_id = ? ORDER BY due_date DESC")) {
                            ps.setInt(1, studentId);
                            ResultSet rs = ps.executeQuery();
                            boolean any = false;
                            while (rs.next()) {
                                any = true;
                                double amt = rs.getDouble("amount");
                                String status = rs.getString("status");
                                if ("Paid".equals(status)) totalPaid += amt; else totalDue += amt;
                    %>
                        <tr>
                            <td><%= rs.getString("fee_type") %></td>
                            <td>&#8377; <%= String.format("%.2f", amt) %></td>
                            <td><%= rs.getDate("due_date") %></td>
                            <td>
                                <% if ("Paid".equals(status)) { %>
                                    <span style="color:#107c10; font-weight:600;">Paid</span>
                                <% } else { %>
                                    <span style="color:#d13438; font-weight:600;">Pending</span>
                                <% } %>
                            </td>
                            <td><%= rs.getDate("paid_date") == null ? "-" : rs.getDate("paid_date") %></td>
                            <td>
                                <% if (!"Paid".equals(status)) { %>
                                    <a href="MarkFeePaidServlet?feeId=<%= rs.getInt("fee_id") %>&studentId=<%= studentId %>">Mark Paid</a>
                                    &nbsp;|&nbsp;
                                <% } %>
                                <a href="DeleteFeeServlet?feeId=<%= rs.getInt("fee_id") %>&studentId=<%= studentId %>"
                                   style="color:#d13438;"
                                   onclick="return confirm('Delete this fee record?');">Delete</a>
                            </td>
                        </tr>
                    <%
                            }
                            if (!any) {
                    %>
                        <tr><td colspan="6" style="text-align:center; color:#6b7280;">No fee records yet.</td></tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <tr><td colspan="6" style="color:#d13438;">Error: <%= e.getMessage() %></td></tr>
                    <% } %>
                </table>

                <div class="stats" style="margin-top: 20px;">
                    <div class="stat">
                        <div class="ico">&#10004;</div>
                        <div><div class="num">&#8377; <%= String.format("%.2f", totalPaid) %></div><div class="lbl">Total Paid</div></div>
                    </div>
                    <div class="stat">
                        <div class="ico">&#9203;</div>
                        <div><div class="num">&#8377; <%= String.format("%.2f", totalDue) %></div><div class="lbl">Total Pending</div></div>
                    </div>
                </div>

                <div style="margin-top: 20px;">
                    <a href="viewStudents.jsp">&larr; Back to Students</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>