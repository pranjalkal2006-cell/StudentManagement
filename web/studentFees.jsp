<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.sms.util.DBConnection"%>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    int studentId = (Integer) session.getAttribute("studentId");
    double totalDue = 0, totalPaid = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Fees - StudentHub</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body>
    <div class="navbar">
        <span class="brand">StudentHub</span>
        <span>
            <a href="studentDashboard.jsp">My Profile</a>
            <a href="studentDocuments.jsp">My Documents</a>
            <a href="studentFees.jsp">My Fees</a>
            <a href="StudentLogoutServlet">Logout</a>
        </span>
    </div>

    <div class="container">
        <div class="panel">
            <h2>My Fee Records</h2>

            <table>
                <tr><th>Fee Type</th><th>Amount</th><th>Due Date</th><th>Status</th><th>Paid Date</th></tr>
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
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="5" style="text-align:center; color:#6b7280;">No fee records yet.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr><td colspan="5" style="color:#d13438;">Error: <%= e.getMessage() %></td></tr>
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
        </div>
    </div>
</body>
</html>