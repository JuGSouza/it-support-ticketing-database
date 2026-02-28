# IT Support Ticketing Database (MySQL)

Relational database design for a simplified IT Support ticketing system.

This project models an internal support environment where users submit tickets, devices are registered, and support agents manage and resolve issues.

## Database Structure

The schema includes the following core entities:

- Teams  
- Users (End Users and Support Agents)  
- Devices  
- Tickets  
- Ticket Comments  

Primary and foreign keys were implemented to ensure proper relational integrity between users, devices, and tickets.

## Functional Scope

The database supports:

- Ticket tracking by status and priority  
- Assignment of tickets to support agents  
- Device association per request  
- Basic operational reporting  

## Analytical Queries

The project includes reporting queries such as:

- Open / In Progress tickets with requester and device details  
- Workload distribution per support agent  
- Ticket volume by status and category  
- Comment count per ticket  

These queries simulate common internal reporting needs within an IT Support team.

## Tools

- MySQL 8.0  
- MySQL Workbench  

## Execution

1. Run `schema.sql` to create the database and populate sample data.  
2. Run `queries.sql` to execute reporting queries.