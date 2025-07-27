import 'package:daytask/models/note.dart';
import 'package:daytask/services/api_service.dart';
import 'package:flutter/material.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _showArchivedOnly = false;

  // Getters
  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get showArchivedOnly => _showArchivedOnly;

  // Get active (non-archived) notes
  List<Note> get activeNotes =>
      _notes.where((note) => !note.isArchived).toList();

  // Get archived notes
  List<Note> get archivedNotes =>
      _notes.where((note) => note.isArchived).toList();

  // Get notes count
  int get totalNotesCount => _notes.length;
  int get activeNotesCount => activeNotes.length;
  int get archivedNotesCount => archivedNotes.length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setNotes(List<Note> notes) {
    _notes = notes;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and archive filters
  void _applyFilters() {
    List<Note> filtered = _notes;

    // Filter by archive status
    if (_showArchivedOnly) {
      filtered = filtered.where((note) => note.isArchived).toList();
    } else {
      filtered = filtered.where((note) => !note.isArchived).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
    }

    // Sort by updatedAt (most recent first)
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _filteredNotes = filtered;
  }

  // Fetch all notes from API
  Future<void> fetchNotes() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.getAllNotes();
      final List<dynamic> notesData = response as List<dynamic>;

      final notes = notesData
          .map((noteData) => Note.fromJson(noteData))
          .toList();
      _setNotes(notes);
    } catch (e) {
      _setError('Failed to fetch notes: ${e.toString()}');
    }

    _setLoading(false);
  }

  // Create a new note
  Future<bool> createNote(
    String title,
    String content, {
    List<String>? tags,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.createNote(title, content);
      final newNote = Note.fromJson(response);

      // Add to local list and refresh filters
      _notes.insert(0, newNote);
      _applyFilters();
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create note: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update an existing note
  Future<bool> updateNote(
    String noteId,
    String title,
    String content, {
    List<String>? tags,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.updateNote(noteId, title, content);
      final updatedNote = Note.fromJson(response);

      // Update local list
      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _notes[index] = updatedNote;
        _applyFilters();
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update note: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(String noteId) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.deleteNote(noteId);

      // Remove from local list
      _notes.removeWhere((note) => note.id == noteId);
      _applyFilters();
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete note: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Archive/Unarchive a note
  Future<bool> toggleArchiveNote(String noteId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.archiveNote(noteId);
      final updatedNote = Note.fromJson(response);

      // Update local list
      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _notes[index] = updatedNote;
        _applyFilters();
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to archive note: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Search notes
  Future<void> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      // If query is empty, just filter locally
      _searchQuery = '';
      _applyFilters();
      notifyListeners();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Use API search for more comprehensive results
      final response = await ApiService.searchNote(query);
      final List<dynamic> notesData = response as List<dynamic>;

      final searchResults = notesData
          .map((noteData) => Note.fromJson(noteData))
          .toList();

      // Update search query and show results
      _searchQuery = query;
      _notes = searchResults;
      _applyFilters();
    } catch (e) {
      // Fallback to local search if API search fails
      _searchQuery = query;
      _applyFilters();
      _setError('Search failed, showing local results');
    }

    _setLoading(false);
  }

  // Set local search query (for local filtering)
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Toggle between showing active and archived notes
  void toggleShowArchived() {
    _showArchivedOnly = !_showArchivedOnly;
    _applyFilters();
    notifyListeners();
  }

  // Set archive filter
  void setShowArchived(bool showArchived) {
    _showArchivedOnly = showArchived;
    _applyFilters();
    notifyListeners();
  }

  // Get a specific note by ID
  Note? getNoteById(String noteId) {
    try {
      return _notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  // Get notes by tag
  List<Note> getNotesByTag(String tag) {
    return _notes
        .where(
          (note) => note.tags.any(
            (noteTag) => noteTag.toLowerCase() == tag.toLowerCase(),
          ),
        )
        .toList();
  }

  // Get all unique tags
  List<String> getAllTags() {
    final Set<String> allTags = {};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }

  // Filter notes by date range
  List<Note> getNotesInDateRange(DateTime startDate, DateTime endDate) {
    return _notes.where((note) {
      return note.createdAt.isAfter(startDate) &&
          note.createdAt.isBefore(endDate);
    }).toList();
  }

  // Get recent notes (last 7 days)
  List<Note> getRecentNotes() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return getNotesInDateRange(sevenDaysAgo, DateTime.now());
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Refresh notes (pull to refresh)
  Future<void> refreshNotes() async {
    await fetchNotes();
  }

  // Add a note locally (for optimistic updates)
  void addNoteLocally(Note note) {
    _notes.insert(0, note);
    _applyFilters();
    notifyListeners();
  }

  // Update a note locally (for optimistic updates)
  void updateNoteLocally(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      _applyFilters();
      notifyListeners();
    }
  }

  // Remove a note locally (for optimistic updates)
  void removeNoteLocally(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    _applyFilters();
    notifyListeners();
  }
}
