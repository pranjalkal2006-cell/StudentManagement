package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddStudentServlet")
public class AddStudentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String rollNo = request.getParameter("rollNo");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String courseId = request.getParameter("courseId");
        String year = request.getParameter("year");
        String[] clubIds = request.getParameterValues("clubIds");

        if (rollNo == null || rollNo.trim().isEmpty()
                || name == null || name.trim().isEmpty()
                || courseId == null || courseId.trim().isEmpty()
                || year == null || year.trim().isEmpty()) {
            response.sendRedirect("addStudent.jsp?error=required");
            return;
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.trim().matches("\\d{10}")) {
            response.sendRedirect("addStudent.jsp?error=phone");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO students (roll_no, name, email, phone, course_id, year, password) " +
                "VALUES (?, ?, ?, ?, ?, ?, SHA2(?, 256))",
                Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, rollNo.trim());
            ps.setString(2, name.trim());
            ps.setString(3, (email == null || email.trim().isEmpty()) ? null : email.trim());
            ps.setString(4, (phone == null || phone.trim().isEmpty()) ? null : phone.trim());
            ps.setInt(5, Integer.parseInt(courseId));
            ps.setInt(6, Integer.parseInt(year));
            ps.setString(7, rollNo.trim());
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            int newStudentId = 0;
            if (keys.next()) newStudentId = keys.getInt(1);

            if (clubIds != null && newStudentId > 0) {
                PreparedStatement cs = con.prepareStatement(
                    "INSERT INTO student_clubs (student_id, club_id) VALUES (?, ?)");
                for (String cid : clubIds) {
                    cs.setInt(1, newStudentId);
                    cs.setInt(2, Integer.parseInt(cid));
                    cs.executeUpdate();
                }
            }

            response.sendRedirect("addStudent.jsp?success=1");

        } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
            response.sendRedirect("addStudent.jsp?error=duplicate");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}