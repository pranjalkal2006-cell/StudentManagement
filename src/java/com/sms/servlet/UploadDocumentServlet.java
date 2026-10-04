package com.sms.servlet;

import com.sms.util.DBConnection;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/UploadDocumentServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5 MB limit
public class UploadDocumentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String studentIdStr = request.getParameter("studentId");
        String docType = request.getParameter("docType");

        if (docType == null || docType.trim().isEmpty()) {
            response.sendRedirect("uploadDocument.jsp?id=" + studentIdStr + "&error=notype");
            return;
        }

        Part filePart;
        try {
            filePart = request.getPart("docFile");
        } catch (Exception e) {
            response.sendRedirect("uploadDocument.jsp?id=" + studentIdStr + "&error=toobig");
            return;
        }

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("uploadDocument.jsp?id=" + studentIdStr + "&error=nofile");
            return;
        }

        String originalName = getFileName(filePart);
        if (originalName == null || !originalName.toLowerCase().endsWith(".pdf")) {
            response.sendRedirect("uploadDocument.jsp?id=" + studentIdStr + "&error=notpdf");
            return;
        }

        try {
            int studentId = Integer.parseInt(studentIdStr);

            // Save the file to the uploads folder, name it uniquely
            String uploadDir = getServletContext().getRealPath("/uploads");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String savedName = "student" + studentId + "_" + System.currentTimeMillis() + ".pdf";
            String fullPath = uploadDir + File.separator + savedName;
            filePart.write(fullPath);

            // Save a record in the database (store the relative path)
            String relativePath = "uploads/" + savedName;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO student_documents (student_id, doc_type, file_name, file_path) " +
                     "VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, studentId);
                ps.setString(2, docType);
                ps.setString(3, originalName);
                ps.setString(4, relativePath);
                ps.executeUpdate();
            }

            response.sendRedirect("viewDocuments.jsp?id=" + studentId + "&uploaded=1");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        for (String token : header.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).replace("\"", "");
            }
        }
        return null;
    }
}