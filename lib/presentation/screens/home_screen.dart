import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const scaffoldBackgroundColor = Color(0xff202832);
const searchFieldFillColor = Color(0xff455A64);

int currentIndex = 0;

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: searchFieldFillColor,
                        hintText: 'Search Tasks',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xffFED36A),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Completed Tasks',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to completed tasks screen
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: const Color(0xffFED36A),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Placeholder for completed tasks list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 200,
                      height: 120,
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task ${index + 1}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description for completed task ${index + 1}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ongoing Tasks',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to ongoing tasks screen
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: const Color(0xffFED36A),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task ${index + 1}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description for ongoing task ${index + 1}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Handle add button tap
          } else {
            setState(() {
              currentIndex = index;
            });
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xffFED36A),
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.black, size: 32),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calender',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        selectedItemColor: const Color(0xffFED36A),
        unselectedItemColor: Colors.white70,
        backgroundColor: scaffoldBackgroundColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
