<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*, com.sms.util.DBConnection"%>
<%
    // Only logged-in admins can see this page
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int totalStudents = 0;
    int totalCourses = 0;
    int addedToday = 0;
    List<String> courseNames = new ArrayList<String>();
    List<Integer> courseCounts = new ArrayList<Integer>();
    String dbError = null;

    try (Connection con = DBConnection.getConnection();
         Statement st = con.createStatement()) {

        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM students");
        if (rs.next()) totalStudents = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM courses");
        if (rs.next()) totalCourses = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(*) FROM students WHERE DATE(created_at) = CURDATE()");
        if (rs.next()) addedToday = rs.getInt(1);

        rs = st.executeQuery(
            "SELECT c.course_name, COUNT(s.student_id) AS total " +
            "FROM courses c LEFT JOIN students s ON c.course_id = s.course_id " +
            "GROUP BY c.course_name ORDER BY c.course_name");
        while (rs.next()) {
            courseNames.add(rs.getString(1));
            courseCounts.add(rs.getInt(2));
        }
    } catch (Exception e) {
        dbError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - StudentHub</title>
    <link rel="stylesheet" href="css/style.css?v=3">
    <style>
        .dash { max-width: 1100px; margin: 30px auto; padding: 0 20px; }

        .banner {
            background: linear-gradient(120deg, #0b2a4a, #0aa5b8);
            color: #fff; border-radius: 12px; padding: 32px 34px; margin-bottom: 24px;
        }
        .banner h2 { margin: 0 0 6px; font-size: 28px; color: #fff; }
        .banner p { margin: 0; color: #dbeafe; }

        .stats {
            display: grid; gap: 18px; margin-bottom: 24px;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        }
        .stat {
            background: #fff; border-radius: 10px; padding: 22px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            border-left: 5px solid #0aa5b8;
            display: flex; align-items: center; gap: 16px;
        }
        .stat .ico { font-size: 32px; }
        .stat .num { font-size: 30px; font-weight: 700; color: #0b2a4a; line-height: 1; }
        .stat .lbl { color: #6b7280; font-size: 14px; margin-top: 4px; }

        .grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .box {
            background: #fff; border-radius: 10px; padding: 24px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
        }
        .box h3 { margin: 0 0 16px; color: #0b2a4a; }

        .action {
            display: flex; align-items: center; gap: 14px; padding: 16px;
            border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 12px;
            color: #0b2a4a;
        }
        .action:hover { border-color: #0aa5b8; background: #f0fbfd; text-decoration: none; }
        .action .ico { font-size: 26px; }
        .action strong { display: block; }
        .action span { font-size: 13px; color: #6b7280; }

        .course-row { margin-bottom: 16px; }
        .course-row .top {
            display: flex; justify-content: space-between;
            font-size: 14px; margin-bottom: 6px;
        }
        .bar { background: #e5e7eb; border-radius: 20px; height: 10px; overflow: hidden; }
        .bar div {
            background: linear-gradient(90deg, #0aa5b8, #0b2a4a);
            height: 100%; border-radius: 20px;
        }
        .empty { color: #6b7280; font-size: 14px; }
        .foot { text-align: center; color: #6b7280; font-size: 13px; padding: 24px; }

        @media (max-width: 800px) { .grid2 { grid-template-columns: 1fr; } }
    </style>
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

    <div class="dash">

        <div class="banner">
            <h2>Welcome back, <%= session.getAttribute("admin") %></h2>
            <p>Here is an overview of your student records.</p>
        </div>

        <% if (dbError != null) { %>
            <div class="alert alert-error">Could not read data from the database: <%= dbError %></div>
        <% } %>

        <div class="stats">
            <div class="stat">
                <div class="ico">&#127891;</div>
                <div>
                    <div class="num"><%= totalStudents %></div>
                    <div class="lbl">Total Students</div>
                </div>
            </div>
            <div class="stat">
                <div class="ico">&#128218;</div>
                <div>
                    <div class="num"><%= totalCourses %></div>
                    <div class="lbl">Courses</div>
                </div>
            </div>
            <div class="stat">
                <div class="ico">&#10133;</div>
                <div>
                    <div class="num"><%= addedToday %></div>
                    <div class="lbl">Added Today</div>
                </div>
            </div>
        </div>

        <div class="grid2">

            <div class="box">
                <h3>Quick Actions</h3>
                <a class="action" href="addStudent.jsp">
                    <div class="ico">&#128221;</div>
                    <div><strong>Add Student</strong><span>Register a new student record</span></div>
                </a>
                <a class="action" href="viewStudents.jsp">
                    <div class="ico">&#128269;</div>
                    <div><strong>View Students</strong><span>Search, edit or delete records</span></div>
                </a>
            </div>

            <div class="box">
                <h3>Students by Course</h3>
                <% if (courseNames.isEmpty()) { %>
                    <p class="empty">No courses found.</p>
                <% } else {
                       for (int i = 0; i < courseNames.size(); i++) {
                           int count = courseCounts.get(i);
                           int pct = (totalStudents == 0) ? 0 : (count * 100 / totalStudents);
                %>
                    <div class="course-row">
                        <div class="top">
                            <span><%= courseNames.get(i) %></span>
                            <strong><%= count %></strong>
                        </div>
                        <div class="bar"><div style="width: <%= pct %>%;"></div></div>
                    </div>
                <%     }
                   } %>
            </div>

        </div>
    </div>

    <div class="foot">StudentHub - Cloud-Based Student Management System &copy; 2026</div>

</body>
</html>