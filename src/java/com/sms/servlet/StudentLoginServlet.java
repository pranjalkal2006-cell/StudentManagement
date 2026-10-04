package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/StudentLoginServlet")
public class StudentLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String rollNo = request.getParameter("rollNo");
        String password = request.getParameter("password");

        if (rollNo == null || password == null) {
            response.sendRedirect("studentLogin.jsp?error=wrong");
            return;
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT student_id, name FROM students WHERE roll_no = ? AND password = SHA2(?, 256)")) {

            ps.setString(1, rollNo.trim());
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = request.getSession();
                    session.setAttribute("studentId", rs.getInt("student_id"));
                    session.setAttribute("studentName", rs.getString("name"));
                    response.sendRedirect("studentDashboard.jsp");
                } else {
                    response.sendRedirect("studentLogin.jsp?error=wrong");
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}