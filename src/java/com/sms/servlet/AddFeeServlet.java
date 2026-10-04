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

@WebServlet("/AddFeeServlet")
public class AddFeeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String studentIdStr = request.getParameter("studentId");
        String feeType = request.getParameter("feeType");
        String amountStr = request.getParameter("amount");
        String dueDate = request.getParameter("dueDate");

        if (feeType == null || feeType.trim().isEmpty()
                || amountStr == null || amountStr.trim().isEmpty()
                || dueDate == null || dueDate.trim().isEmpty()) {
            response.sendRedirect("addFee.jsp?id=" + studentIdStr + "&error=required");
            return;
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO student_fees (student_id, fee_type, amount, due_date) " +
                 "VALUES (?, ?, ?, ?)")) {

            int studentId = Integer.parseInt(studentIdStr);
            ps.setInt(1, studentId);
            ps.setString(2, feeType.trim());
            ps.setDouble(3, Double.parseDouble(amountStr));
            ps.setString(4, dueDate);
            ps.executeUpdate();

            response.sendRedirect("viewFees.jsp?id=" + studentId + "&added=1");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}