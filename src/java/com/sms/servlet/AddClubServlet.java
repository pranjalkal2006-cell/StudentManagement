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

@WebServlet("/AddClubServlet")
public class AddClubServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String clubName = request.getParameter("clubName");
        if (clubName == null || clubName.trim().isEmpty()) {
            response.sendRedirect("manageClubs.jsp?error=empty");
            return;
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO clubs (club_name) VALUES (?)")) {
            ps.setString(1, clubName.trim());
            ps.executeUpdate();
            response.sendRedirect("manageClubs.jsp?success=1");
        } catch (java.sql.SQLIntegrityConstraintViolationException dup) {
            response.sendRedirect("manageClubs.jsp?error=duplicate");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}