<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = request.getParameter("error");
    int wait = 0;
    int left = 0;
    try { wait = Integer.parseInt(request.getParameter("wait")); } catch (Exception e) { }
    try { left = Integer.parseInt(request.getParameter("left")); } catch (Exception e) { }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Login</title>
    <link rel="stylesheet" href="css/style.css?v=3">
</head>
<body class="login-page">
    <div class="login-wrap">

        <div class="login-left">
            <h2>Welcome</h2>
            <p>Sign in to manage student records.</p>
            <a class="btn btn-outline" href="index.html">&larr; Back to Home</a>
        </div>

        <div class="login-right">
            <h2>Admin Login</h2>
            <p class="subtitle">Enter your credentials to continue</p>

            <% if ("wrong".equals(error)) { %>
                <div class="alert alert-error">
                    Wrong username or password. <%= left %> attempt(s) left.
                </div>
            <% } else if ("locked".equals(error)) { %>
                <div class="alert alert-error">
                    Too many failed attempts. Try again in <%= wait %> seconds.
                </div>
            <% } else if ("invalid".equals(error)) { %>
                <div class="alert alert-error">
                    Username must be 3 to 30 characters and password 6 to 20 characters.
                </div>
            <% } %>

            <form action="LoginServlet" method="post">
                <input type="text" name="username" placeholder="User Name (3-30 characters)"
                       minlength="3" maxlength="30" required>

                <input type="password" id="password" name="password"
                       placeholder="Password (6-20 characters)"
                       minlength="6" maxlength="20" required>

                <label style="display:flex; align-items:center; gap:8px; font-weight:400; margin:-4px 0 14px;">
                    <input type="checkbox" style="width:auto; margin:0;" onclick="togglePassword()">
                    Show password
                </label>

                <div class="btn-row">
                    <button type="submit" class="btn btn-blue">LOGIN</button>
                    <a class="btn btn-cancel" href="index.html">CANCEL</a>
                </div>
            </form>
        </div>

    </div>

    <script>
        function togglePassword() {
            var box = document.getElementById("password");
            box.type = (box.type === "password") ? "text" : "password";
        }
    </script>
</body>
</html>