import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:daytask/constants.dart';
import 'package:daytask/providers/auth_provider.dart';
import 'package:daytask/providers/note_provider.dart';
import 'package:daytask/models/note.dart';
import 'package:daytask/core/routes/app_router.gr.dart'; // Import your generated auto_route file

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    await noteProvider.fetchNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final noteProvider = Provider.of<NoteProvider>(
              context,
              listen: false,
            );
            await noteProvider.refreshNotes();
          },
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Header(),
                normalHeight,
                SearchRow(controller: _searchController),
                normalHeight,
                const CompletedNotes(),
                minimumHeight,
                const CompletedNotesList(),
                normalHeight,
                const OngoingNotes(),
                const OngoingNotesList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          // Always update the currentIndex to reflect the selected tab visually
          setState(() {
            currentIndex = index;
          });

          // Handle navigation based on the tapped index
          switch (index) {
            case 0: // Home
              // If already on Home, no explicit action needed.
              // You could pop until root if you want to ensure no stack build-up
              // context.router.popUntilRoot();
              break;
            case 1: // Chat
              context.router.push(const ChatRoute());
              break;
            case 2: // Add Button (Custom icon)
              _showCreateNoteDialog(context);
              break;
            case 3: // Calendar
              context.router.push(const CalendarRoute());
              break;
            case 4: // Notifications
              // TODO: Implement navigation to NotificationsScreen
              // context.router.push(const NotificationsRoute());
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          // The custom 'Add' button is at index 2
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xffFED36A),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
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
            label: '', // No label for the add button as it's a custom icon
          ),
          // Calendar is now at index 3
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          // Notifications is now at index 4
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

  void _showCreateNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff2C2C2E),
        title: Text(
          'Create New Note',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Note title',
                hintStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xffFED36A)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Note content',
                hintStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xffFED36A)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              return ElevatedButton(
                onPressed: noteProvider.isLoading
                    ? null
                    : () async {
                        if (titleController.text.trim().isNotEmpty &&
                            contentController.text.trim().isNotEmpty) {
                          final success = await noteProvider.createNote(
                            titleController.text.trim(),
                            contentController.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Note created successfully!'),
                                backgroundColor: Color(0xffFED36A),
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFED36A),
                  foregroundColor: Colors.black,
                ),
                child: noteProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Create', style: GoogleFonts.inter()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Header with user info
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                if (authProvider.user != null)
                  Text(
                    authProvider.user!.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffFED36A),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // Show user menu or navigate to profile
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white24,
                child: Text(
                  authProvider.user?.name.isNotEmpty == true
                      ? authProvider.user!.name[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Search Row with real search functionality
class SearchRow extends StatelessWidget {
  final TextEditingController controller;

  const SearchRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  noteProvider.setSearchQuery(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: searchFieldFillColor,
                  hintText: 'Search Notes',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: noteProvider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            controller.clear();
                            noteProvider.clearSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                noteProvider.toggleShowArchived();
              },
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: noteProvider.showArchivedOnly
                      ? const Color(0xffFED36A)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  noteProvider.showArchivedOnly
                      ? Icons.unarchive
                      : Icons.archive,
                  color: noteProvider.showArchivedOnly
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Completed Notes (Archived Notes)
class CompletedNotes extends StatelessWidget {
  const CompletedNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        return Row(
          children: [
            Expanded(
              child: Text(
                'Archived Notes (${noteProvider.archivedNotesCount})',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                noteProvider.setShowArchived(true);
              },
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: const Color(0xffFED36A),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Completed Notes List (Archived Notes)
class CompletedNotesList extends StatelessWidget {
  const CompletedNotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final archivedNotes = noteProvider.archivedNotes.take(5).toList();

        if (archivedNotes.isEmpty) {
          return Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No archived notes yet',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: archivedNotes.asMap().entries.map((entry) {
              final index = entry.key;
              final note = entry.value;

              return NoteCard(
                note: note,
                isHighlighted: index == 0,
                isHorizontal: true,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// Ongoing Notes (Active Notes)
class OngoingNotes extends StatelessWidget {
  const OngoingNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        return Row(
          children: [
            Expanded(
              child: Text(
                'Active Notes (${noteProvider.activeNotesCount})',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                noteProvider.setShowArchived(false);
              },
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: const Color(0xffFED36A),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Ongoing Notes List (Active Notes)
class OngoingNotesList extends StatelessWidget {
  const OngoingNotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (noteProvider.isLoading && noteProvider.notes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xffFED36A)),
          );
        }

        if (noteProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Error: ${noteProvider.error}',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          );
        }

        final activeNotes = noteProvider.showArchivedOnly
            ? noteProvider.notes
            : noteProvider.activeNotes;

        if (activeNotes.isEmpty) {
          return Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.note_add, color: Colors.white70, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'No notes yet. Tap + to create one!',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: activeNotes.map((note) {
            return NoteCard(note: note, isHorizontal: false);
          }).toList(),
        );
      },
    );
  }
}

// Reusable Note Card Widget
class NoteCard extends StatelessWidget {
  final Note note;
  final bool isHighlighted;
  final bool isHorizontal;

  const NoteCard({
    super.key,
    required this.note,
    this.isHighlighted = false,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        return Container(
          width: isHorizontal ? 200 : double.infinity,
          height: isHorizontal ? 180 : 120,
          margin: isHorizontal
              ? const EdgeInsets.only(right: 15)
              : const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xffFED36A) : Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.inter(
                        color: isHighlighted ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isHighlighted ? Colors.black : Colors.white70,
                      size: 16,
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        case 'archive':
                          await noteProvider.toggleArchiveNote(note.id);
                          break;
                        case 'delete':
                          _showDeleteDialog(context, noteProvider, note);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'archive',
                        child: Text(note.isArchived ? 'Unarchive' : 'Archive'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: GoogleFonts.inter(
                    color: isHighlighted ? Colors.black87 : Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: isHorizontal ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: note.tags.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isHighlighted ? Colors.black12 : Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isHighlighted ? Colors.black : Colors.white70,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    NoteProvider noteProvider,
    Note note,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff2C2C2E),
        title: Text(
          'Delete Note',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await noteProvider.deleteNote(note.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}
