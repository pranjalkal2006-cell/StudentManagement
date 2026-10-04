package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.File;
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

@WebServlet("/DeleteDocumentServlet")
public class DeleteDocumentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int docId = Integer.parseInt(request.getParameter("docId"));
            String studentId = request.getParameter("studentId");

            try (Connection con = DBConnection.getConnection()) {

                PreparedStatement getPath = con.prepareStatement(
                    "SELECT file_path FROM student_documents WHERE doc_id = ?");
                getPath.setInt(1, docId);
                ResultSet rs = getPath.executeQuery();
                if (rs.next()) {
                    String relativePath = rs.getString("file_path");
                    String fullPath = getServletContext().getRealPath("/" + relativePath);
                    File file = new File(fullPath);
                    if (file.exists()) file.delete();
                }

                PreparedStatement del = con.prepareStatement(
                    "DELETE FROM student_documents WHERE doc_id = ?");
                del.setInt(1, docId);
                del.executeUpdate();
            }

            response.sendRedirect("viewDocuments.jsp?id=" + studentId + "&deleted=1");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}