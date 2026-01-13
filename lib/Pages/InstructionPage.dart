import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Pages/ModulePage.dart';
import 'package:flutter_application_final_project/theme/app_theme.dart';
import 'package:introduction_screen/introduction_screen.dart';

class InstructionPage extends StatelessWidget {
  final bool isLecturer;

  const InstructionPage({super.key, required this.isLecturer});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      dotsFlex: 0,
      pages: isLecturer ? _getLecturerPages() : _getStudentPages(),
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Text('Next', style: TextStyle(fontWeight: FontWeight.w600)),
      done: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ModulePage(title: 'Welcome'),
          ),
        );
      },
      onSkip: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ModulePage(title: 'Welcome'),
          ),
        );
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppTheme.primaryColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  List<PageViewModel> _getStudentPages() {
    return [
      PageViewModel(
        title: "Welcome Student!",
        body: "Learn how to use the AACARDS-APP to organize your study materials and track your progress.",
        image: _buildImage('assets/student_welcome.png', Icons.school),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Navigation Structure",
        body: "Navigate through: Module → Topic → Subtopic → Sub-subtopic → Card Page\n\nEach level organizes your content hierarchically.",
        image: _buildImage('assets/navigation.png', Icons.navigation),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Create Modules",
        body: "You can create new modules using the 'Add Module' button. Modules help you organize your subjects and courses.",
        image: _buildImage('assets/create_module.png', Icons.add_circle),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Card Page Features",
        body: "In the Card Page, you can:\n• Write and edit notes\n• Save your work\n• Upload and download files\n• View feedback from lecturers\n• Take quizzes",
        image: _buildImage('assets/card_features.png', Icons.credit_card),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Notes Management",
        body: "Write your notes in the card page. Remember to click 'Save' to store your changes. You can edit or delete your notes anytime.",
        image: _buildImage('assets/notes.png', Icons.note),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "File Management",
        body: "Download files uploaded by your lecturer for each card. You can also upload your own files to the database.",
        image: _buildImage('assets/files.png', Icons.file_upload),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Feedback & Quiz",
        body: "View feedback from your lecturer on your notes. Take quizzes created by your lecturer to test your knowledge.",
        image: _buildImage('assets/feedback.png', Icons.feedback),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Profile & Logout",
        body: "Access your profile from the top right icon. Logout from the top left icon when you're done.",
        image: _buildImage('assets/profile.png', Icons.person),
        decoration: _getPageDecoration(),
      ),
    ];
  }

  List<PageViewModel> _getLecturerPages() {
    return [
      PageViewModel(
        title: "Welcome Lecturer!",
        body: "Learn how to use the AACARDS-APP to create content for your students and provide feedback.",
        image: _buildImage('assets/lecturer_welcome.png', Icons.person),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Select Student",
        body: "First, select a student from the dropdown menu. You can view and manage cards for each student individually.",
        image: _buildImage('assets/select_student.png', Icons.person_search),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Navigation Structure",
        body: "Navigate through: Module → Topic → Subtopic → Sub-subtopic → Card Page\n\nCreate content at each level for your students.",
        image: _buildImage('assets/navigation.png', Icons.navigation),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Create Content",
        body: "Create modules, topics, subtopics, and cards for your students. Use the 'Add Module' button to start creating content.",
        image: _buildImage('assets/create_content.png', Icons.add_circle),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Card Management",
        body: "In Card Pages, you can:\n• Create and edit cards for students\n• Upload files for students to download\n• and download files, that student upload \n• Provide feedback on student notes\n• Create quizzes",
        image: _buildImage('assets/card_management.png', Icons.edit),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Student Notes",
        body: "View and review student notes in each card. You can see what students have written and provide feedback accordingly.",
        image: _buildImage('assets/student_notes.png', Icons.note),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Feedback & Quiz Creation",
        body: "Provide feedback on student work using the Feedback button. Create quizzes for students using the 'Create Quiz' button.",
        image: _buildImage('assets/feedback_quiz.png', Icons.quiz),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "File Upload",
        body: "Upload files (PDFs, documents) that students can download. Use the upload button in the card page to share materials.",
        image: _buildImage('assets/upload.png', Icons.cloud_upload),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Change Student",
        body: "Use the 'Change Student' button to switch between different students. Each student has their own set of cards and content.",
        image: _buildImage('assets/change_student.png', Icons.swap_horiz),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Profile & Logout",
        body: "Access your profile from the top right icon. Logout from the top left icon when you're done.",
        image: _buildImage('assets/profile.png', Icons.person),
        decoration: _getPageDecoration(),
      ),
    ];
  }

  Widget _buildImage(String assetPath, IconData fallbackIcon) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        fallbackIcon,
        size: 100,
        color: Colors.white,
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
      bodyTextStyle: const TextStyle(
        fontSize: 16,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: const EdgeInsets.only(top: 40),
      pageColor: AppTheme.backgroundColor,
    );
  }
}
