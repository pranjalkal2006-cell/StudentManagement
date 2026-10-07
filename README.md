# StudentHub - Cloud-Based Student Management System

A web-based student management system deployed on Microsoft Azure, built with Java Servlets, JSP, and MySQL.

## Live Demo
http://20.194.6.92:8080/StudentManagement/

*(Note: This is a student project hosted on a personal Azure VM for academic purposes. The demo may be temporarily offline outside active evaluation periods.)*

## Tech Stack
- Backend: Java Servlets, JSP
- Database: MySQL 8.0
- Server: Apache Tomcat 9
- Cloud: Microsoft Azure (Virtual Machine, IaaS)
- Frontend: HTML, CSS

## Features
- Secure admin login with attempt limiting
- Full student CRUD (Create, Read, Update, Delete)
- Course and Club management
- PDF document upload per student
- Fee tracking with payment status
- Separate student self-login portal

## Architecture
Deployed on an Azure Virtual Machine running Apache Tomcat 9 and MySQL 8. 
Configured with a Network Security Group for inbound port access (22, 80, 8080).

## Future Improvements
- Managed database service (Azure Database for MySQL)
- HTTPS/SSL
- Connection pooling for improved performance
