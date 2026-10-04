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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    // You can change these numbers
    private static final int MAX_ATTEMPTS = 3;
    private static final long LOCK_TIME_MS = 60 * 1000;   // 60 seconds

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // 1. Is the user locked out right now?
        Long lockUntil = (Long) session.getAttribute("lockUntil");
        if (lockUntil != null) {
            long now = System.currentTimeMillis();
            if (now < lockUntil) {
                long secondsLeft = (lockUntil - now) / 1000 + 1;
                response.sendRedirect("login.jsp?error=locked&wait=" + secondsLeft);
                return;
            }
            // Lock time is over, so reset
            session.removeAttribute("lockUntil");
            session.setAttribute("attempts", 0);
        }

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 2. Check the length rules
        if (username == null || password == null) {
            response.sendRedirect("login.jsp?error=invalid");
            return;
        }
        username = username.trim();
        if (username.length() < 3 || username.length() > 30
                || password.length() < 6 || password.length() > 20) {
            response.sendRedirect("login.jsp?error=invalid");
            return;
        }

        // 3. Check the database
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT admin_id FROM admin WHERE username = ? AND password = SHA2(?, 256)")) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Correct login
                    session.removeAttribute("attempts");
                    session.setAttribute("admin", username);
                    response.sendRedirect("dashboard.jsp");
                } else {
                    // Wrong login: count the attempt
                    Integer attempts = (Integer) session.getAttribute("attempts");
                    attempts = (attempts == null) ? 1 : attempts + 1;
                    session.setAttribute("attempts", attempts);

                    if (attempts >= MAX_ATTEMPTS) {
                        session.setAttribute("lockUntil",
                                System.currentTimeMillis() + LOCK_TIME_MS);
                        response.sendRedirect("login.jsp?error=locked&wait="
                                + (LOCK_TIME_MS / 1000));
                    } else {
                        response.sendRedirect("login.jsp?error=wrong&left="
                                + (MAX_ATTEMPTS - attempts));
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}