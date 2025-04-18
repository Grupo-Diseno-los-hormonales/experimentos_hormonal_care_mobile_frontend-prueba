import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoAppointment extends StatelessWidget {
  final String patientName;
  final String appointmentTime;
  final String endTime;
  final String appointmentDate;
  final String title;
  final String description;
  final Color color;

  InfoAppointment({
    required this.patientName,
    required this.appointmentTime,
    required this.endTime,
    required this.appointmentDate,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Appointment Details',
                style: TextStyle(
                  color: Color(0xFF40535B),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06,
                ),
              ),
              _buildInfoCard(Icons.title, 'Title', title, screenWidth),
              SizedBox(height: screenHeight * 0.015),
              _buildInfoCard(Icons.person, 'Patient', patientName, screenWidth),
              SizedBox(height: screenHeight * 0.015),
              _buildInfoCard(Icons.calendar_today, 'Date', appointmentDate, screenWidth),
              SizedBox(height: screenHeight * 0.015),
              _buildInfoCard(Icons.access_time, 'Start Time', appointmentTime, screenWidth),
              SizedBox(height: screenHeight * 0.015),
              _buildInfoCard(Icons.access_time, 'End Time', endTime, screenWidth),
              SizedBox(height: screenHeight * 0.015),
              _buildDescriptionCard(context, screenWidth),
              SizedBox(height: screenHeight * 0.015),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Fondo claro
                  foregroundColor: Color(0xFF40535B), // Texto oscuro
                  textStyle: TextStyle(
                    color: Color(0xFF40535B),
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                  shadowColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, double screenWidth) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF00796B), size: screenWidth * 0.07),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00796B),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.005),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Color(0xFF00796B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, double screenWidth) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
        child: Row(
          children: [
            Icon(Icons.description, color: Color(0xFF00796B), size: screenWidth * 0.07),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00796B),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.005),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Color(0xFF00796B),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: Color(0xFF00796B)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: description));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}