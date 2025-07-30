import 'package:daytask/models/note.dart';
import 'package:daytask/services/api_service.dart';
import 'package:flutter/material.dart';

class NoteProvider with ChangeNotifier {
  // The complete, unfiltered list of all notes fetched from the API
  List<Note> _allNotes = [];
  // The list currently displayed to the UI after applying filters (search, archive)
  List<Note> _filteredNotes = [];

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _showArchivedOnly = false; // False means show active notes

  // Getters for external access
  List<Note> get notes => _filteredNotes; // UI consumes this
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get showArchivedOnly => _showArchivedOnly;

  // Get active (non-archived) notes from the full list
  List<Note> get activeNotes =>
      _allNotes.where((note) => !note.isArchived).toList();

  // Get archived notes from the full list
  List<Note> get archivedNotes =>
      _allNotes.where((note) => note.isArchived).toList();

  // Get notes count from the full list
  int get totalNotesCount => _allNotes.length;
  int get activeNotesCount => activeNotes.length;
  int get archivedNotesCount => archivedNotes.length;

  /// Internal helper to set loading state and notify.
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      // Only update and notify if status changed
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Internal helper to set error message and notify.
  void _setError(String? error) {
    if (_error != error) {
      // Only update and notify if error message changed
      _error = error;
      notifyListeners();
    }
  }

  /// Applies search and archive filters to `_allNotes` and updates `_filteredNotes`.
  /// This method does NOT call notifyListeners(), as it's a helper for other methods
  /// that will call notifyListeners() once all state changes are complete.
  void _applyFilters() {
    List<Note> tempFiltered = List.from(
      _allNotes,
    ); // Start with a copy of all notes

    // 1. Filter by archive status
    if (_showArchivedOnly) {
      tempFiltered = tempFiltered.where((note) => note.isArchived).toList();
    } else {
      tempFiltered = tempFiltered.where((note) => !note.isArchived).toList();
    }

    // 2. Apply search filter
    if (_searchQuery.isNotEmpty) {
      tempFiltered = tempFiltered.where((note) {
        final query = _searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // 3. Sort by updatedAt (most recent first)
    tempFiltered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _filteredNotes = tempFiltered;
  }

  /// Fetches all notes from the API.
  Future<void> fetchNotes() async {
    if (_isLoading) return; // Prevent concurrent fetches
    _setLoading(true); // Will notify listeners
    _setError(null); // Will notify listeners

    try {
      final response = await ApiService.getAllNotes();
      final List<dynamic> notesData = response as List<dynamic>;

      _allNotes = notesData.map((noteData) => Note.fromJson(noteData)).toList();
      _applyFilters(); // Update _filteredNotes based on new _allNotes and current filters
      notifyListeners(); // Notify UI that notes and filters are updated
    } catch (e) {
      _setError(
        'Failed to fetch notes: ${e.toString()}',
      ); // Will notify listeners
    } finally {
      _setLoading(false); // Will notify listeners
    }
  }

  /// Creates a new note via API.
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

      _allNotes.insert(0, newNote); // Add to the full list
      _applyFilters(); // Re-apply filters including the new note
      notifyListeners(); // Notify UI after all updates

      return true;
    } catch (e) {
      _setError('Failed to create note: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing note via API.
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

      final index = _allNotes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _allNotes[index] = updatedNote; // Update in the full list
        _applyFilters(); // Re-apply filters
        notifyListeners(); // Notify UI after all updates
      }

      return true;
    } catch (e) {
      _setError('Failed to update note: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a note via API.
  Future<bool> deleteNote(String noteId) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.deleteNote(noteId);

      _allNotes.removeWhere(
        (note) => note.id == noteId,
      ); // Remove from the full list
      _applyFilters(); // Re-apply filters
      notifyListeners(); // Notify UI after all updates

      return true;
    } catch (e) {
      _setError('Failed to delete note: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles the archive status of a note via API.
  Future<bool> toggleArchiveNote(String noteId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.archiveNote(noteId);
      final updatedNote = Note.fromJson(response);

      final index = _allNotes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _allNotes[index] = updatedNote; // Update in the full list
        _applyFilters(); // Re-apply filters (which will hide/show based on archive filter)
        notifyListeners(); // Notify UI after all updates
      }

      return true;
    } catch (e) {
      _setError('Failed to archive note: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sets the search query and re-applies filters locally.
  /// Does NOT trigger API search. For API search, call `fetchNotes()` again
  /// or implement a separate API search method if your backend supports it efficiently.
  void setSearchQuery(String query) {
    if (_searchQuery == query.trim()) return; // No change, no need to update

    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners(); // Notify UI of filter change
  }

  /// Clears the current search query.
  void clearSearch() {
    if (_searchQuery.isEmpty) return; // Already empty

    _searchQuery = '';
    _applyFilters();
    notifyListeners(); // Notify UI of filter change
  }

  /// Toggles between showing active and archived notes.
  void toggleShowArchived() {
    _showArchivedOnly = !_showArchivedOnly;
    _applyFilters();
    notifyListeners(); // Notify UI of filter change
  }

  /// Explicitly sets whether to show archived notes.
  void setShowArchived(bool showArchived) {
    if (_showArchivedOnly == showArchived) return; // No change

    _showArchivedOnly = showArchived;
    _applyFilters();
    notifyListeners(); // Notify UI of filter change
  }

  /// Gets a specific note by ID from the complete list.
  Note? getNoteById(String noteId) {
    try {
      return _allNotes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  /// Gets notes by a specific tag from the complete list.
  List<Note> getNotesByTag(String tag) {
    return _allNotes
        .where(
          (note) => note.tags.any(
            (noteTag) => noteTag.toLowerCase() == tag.toLowerCase(),
          ),
        )
        .toList();
  }

  /// Gets all unique tags from the complete list.
  List<String> getAllTags() {
    final Set<String> allTags = {};
    for (final note in _allNotes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }

  /// Filters notes by date range from the complete list.
  List<Note> getNotesInDateRange(DateTime startDate, DateTime endDate) {
    return _allNotes.where((note) {
      // Use isAfter and isBefore for strict range, or isAtSameMomentAs for inclusive
      return note.createdAt.isAfter(
            startDate.subtract(const Duration(microseconds: 1)),
          ) && // Ensure start is inclusive
          note.createdAt.isBefore(
            endDate.add(const Duration(microseconds: 1)),
          ); // Ensure end is inclusive
    }).toList();
  }

  /// Gets recent notes (last 7 days) from the complete list.
  List<Note> getRecentNotes() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return getNotesInDateRange(sevenDaysAgo, DateTime.now());
  }

  /// Clears any current error message.
  void clearError() {
    _setError(null); // Will notify listeners
  }

  /// Refreshes notes by re-fetching from the API.
  Future<void> refreshNotes() async {
    await fetchNotes(); // Re-fetches, re-filters, and notifies
  }

  // --- Optimistic Update Helpers ---
  // These modify _allNotes directly, then trigger _applyFilters and notify.

  /// Adds a note locally, useful for optimistic UI updates.
  void addNoteLocally(Note note) {
    _allNotes.insert(0, note);
    _applyFilters();
    notifyListeners();
  }

  /// Updates a note locally, useful for optimistic UI updates.
  void updateNoteLocally(Note updatedNote) {
    final index = _allNotes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _allNotes[index] = updatedNote;
      _applyFilters();
      notifyListeners();
    }
  }

  /// Removes a note locally, useful for optimistic UI updates.
  void removeNoteLocally(String noteId) {
    _allNotes.removeWhere((note) => note.id == noteId);
    _applyFilters();
    notifyListeners();
  }
}
