package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/EditStudentServlet")
public class EditStudentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
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
            response.sendRedirect("editStudent.jsp?id=" + idStr + "&error=required");
            return;
        }
        if (phone != null && !phone.trim().isEmpty() && !phone.trim().matches("\\d{10}")) {
            response.sendRedirect("editStudent.jsp?id=" + idStr + "&error=phone");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            int id = Integer.parseInt(idStr);

            PreparedStatement ps = con.prepareStatement(
                "UPDATE students SET roll_no=?, name=?, email=?, phone=?, course_id=?, year=? " +
                "WHERE student_id=?");

            ps.setString(1, rollNo.trim());
            ps.setString(2, name.trim());
            ps.setString(3, (email == null || email.trim().isEmpty()) ? null : email.trim());
            ps.setString(4, (phone == null || phone.trim().isEmpty()) ? null : phone.trim());
            ps.setInt(5, Integer.parseInt(courseId));
            ps.setInt(6, Integer.parseInt(year));
            ps.setInt(7, id);
            ps.executeUpdate();

            // Replace the student's club list: delete old ones, insert the new ticks
            PreparedStatement del = con.prepareStatement(
                "DELETE FROM student_clubs WHERE student_id = ?");
            del.setInt(1, id);
            del.executeUpdate();

            if (clubIds != null) {
                PreparedStatement cs = con.prepareStatement(
                    "INSERT INTO student_clubs (student_id, club_id) VALUES (?, ?)");
                for (String cid : clubIds) {
                    cs.setInt(1, id);
                    cs.setInt(2, Integer.parseInt(cid));
                    cs.executeUpdate();
                }
            }

            response.sendRedirect("viewStudents.jsp");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}