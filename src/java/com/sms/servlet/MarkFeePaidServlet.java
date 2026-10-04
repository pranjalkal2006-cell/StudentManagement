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

@WebServlet("/MarkFeePaidServlet")
public class MarkFeePaidServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int feeId = Integer.parseInt(request.getParameter("feeId"));
            String studentId = request.getParameter("studentId");

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "UPDATE student_fees SET status = 'Paid', paid_date = CURDATE() WHERE fee_id = ?")) {
                ps.setInt(1, feeId);
                ps.executeUpdate();
            }

            response.sendRedirect("viewFees.jsp?id=" + studentId + "&paid=1");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}