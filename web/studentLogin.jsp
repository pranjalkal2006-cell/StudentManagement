<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Student Login</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body class="login-page">
    <div class="login-wrap">

        <div class="login-left">
            <h2>Student Portal</h2>
            <p>View your profile, documents and fee records.</p>
            <a class="btn btn-outline" href="index.html">&larr; Back to Home</a>
        </div>

        <div class="login-right">
            <h2>Student Login</h2>
            <p class="subtitle">Login with your Roll No</p>

            <% if ("wrong".equals(error)) { %>
                <div class="alert alert-error">Wrong Roll No or Password.</div>
            <% } %>

            <form action="StudentLoginServlet" method="post">
                <input type="text" name="rollNo" placeholder="Roll No" required>
                <input type="password" name="password" placeholder="Password (default: your Roll No)" required>
                <div class="btn-row">
                    <button type="submit" class="btn btn-blue">LOGIN</button>
                    <a class="btn btn-cancel" href="index.html">CANCEL</a>
                </div>
            </form>
        </div>

    </div>
</body>
</html>